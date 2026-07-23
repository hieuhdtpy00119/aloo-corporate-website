package com.aloo.cms.config;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.repository.ChatSessionRepository;
import com.aloo.cms.security.AdminUserDetailsService;
import com.aloo.cms.security.CustomUserDetails;
import com.aloo.cms.security.JwtService;
import com.aloo.cms.service.AdminPermissionService;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.lang.NonNull;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import org.springframework.web.socket.server.HandshakeInterceptor;
import org.springframework.web.socket.server.support.DefaultHandshakeHandler;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final String CRM_SCOPE = "crm";

    private final ChatSessionRepository chatSessionRepository;
    private final JwtService jwtService;
    private final AdminUserDetailsService adminUserDetailsService;
    private final AdminPermissionService adminPermissionService;

    @Value("${app.cors.allowed-origin}")
    private String allowedOrigin;

    @Value("${app.cors.include-localhost:false}")
    private boolean includeLocalhost;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOrigins(corsOrigins())
                .addInterceptors(chatHandshakeInterceptor())
                .setHandshakeHandler(new DefaultHandshakeHandler());
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(stompAuthInterceptor());
    }

    private String[] corsOrigins() {
        if (includeLocalhost) {
            return new String[]{allowedOrigin, "http://localhost:5173", "http://127.0.0.1:5173"};
        }
        return new String[]{allowedOrigin};
    }

    private HandshakeInterceptor chatHandshakeInterceptor() {
        return new HandshakeInterceptor() {
            @Override
            public boolean beforeHandshake(
                    @NonNull ServerHttpRequest request,
                    @NonNull ServerHttpResponse response,
                    @NonNull WebSocketHandler wsHandler,
                    @NonNull Map<String, Object> attributes
            ) {
                String query = request.getURI().getQuery();
                if (query != null) {
                    for (String part : query.split("&")) {
                        String[] pair = part.split("=", 2);
                        if (pair.length == 2 && "chatToken".equals(pair[0]) && StringUtils.hasText(pair[1])) {
                            chatSessionRepository.findBySessionToken(pair[1])
                                    .ifPresent(session -> {
                                        attributes.put("chatSessionId", session.getId());
                                        attributes.put("chatRole", "VISITOR");
                                    });
                        }
                    }
                }
                return true;
            }

            @Override
            public void afterHandshake(
                    @NonNull ServerHttpRequest request,
                    @NonNull ServerHttpResponse response,
                    @NonNull WebSocketHandler wsHandler,
                    Exception exception
            ) {
            }
        };
    }

    private ChannelInterceptor stompAuthInterceptor() {
        return new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
                if (accessor == null) {
                    return message;
                }

                if (StompCommand.CONNECT.equals(accessor.getCommand())) {
                    authenticateAdmin(accessor);
                    return message;
                }

                if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
                    String destination = accessor.getDestination();
                    if (destination == null) {
                        return message;
                    }

                    if (destination.startsWith("/topic/admin/")) {
                        requireCrmAdmin(accessor);
                        return message;
                    }

                    if (destination.startsWith("/topic/chat/session.")) {
                        Long destinationSessionId = parseSessionId(destination);
                        if (destinationSessionId == null) {
                            throw new IllegalArgumentException("Invalid chat session destination");
                        }

                        if (isCrmAdmin(accessor)) {
                            return message;
                        }

                        Long visitorSessionId = (Long) accessor.getSessionAttributes().get("chatSessionId");
                        if (visitorSessionId == null || !visitorSessionId.equals(destinationSessionId)) {
                            throw new IllegalArgumentException("Not allowed to subscribe to this chat session");
                        }
                    }
                }

                if (StompCommand.SEND.equals(accessor.getCommand())) {
                    String destination = accessor.getDestination();
                    if (destination != null && destination.equals("/app/chat.admin.send")) {
                        requireCrmAdmin(accessor);
                    }
                }

                return message;
            }
        };
    }

    private void authenticateAdmin(StompHeaderAccessor accessor) {
        String authHeader = accessor.getFirstNativeHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            return;
        }

        String token = authHeader.substring(BEARER_PREFIX.length());
        try {
            String email = jwtService.extractEmail(token);
            UserDetails userDetails = adminUserDetailsService.loadAnyUserByUsername(email);
            if (!jwtService.isTokenValid(token, userDetails)) {
                return;
            }
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    userDetails,
                    null,
                    userDetails.getAuthorities()
            );
            accessor.setUser(authentication);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        } catch (RuntimeException ignored) {
        }
    }

    private void requireCrmAdmin(StompHeaderAccessor accessor) {
        if (!isCrmAdmin(accessor)) {
            throw new IllegalArgumentException("CRM admin authentication required");
        }
    }

    private boolean isCrmAdmin(StompHeaderAccessor accessor) {
        var user = accessor.getUser();
        if (!(user instanceof Authentication authentication)) {
            return false;
        }
        if (!(authentication.getPrincipal() instanceof CustomUserDetails details)) {
            return false;
        }
        AdminUser adminUser = details.getUser();
        if (adminUser == null || adminUser.getRole() != UserRole.ADMIN) {
            return false;
        }
        return adminPermissionService.resolveScopes(adminUser).contains(CRM_SCOPE);
    }

    private Long parseSessionId(String destination) {
        String prefix = "/topic/chat/session.";
        if (!destination.startsWith(prefix)) {
            return null;
        }
        try {
            return Long.parseLong(destination.substring(prefix.length()));
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
