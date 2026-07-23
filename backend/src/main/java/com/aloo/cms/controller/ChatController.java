package com.aloo.cms.controller;

import com.aloo.cms.dto.ChatSessionCreateRequest;
import com.aloo.cms.dto.ChatSessionResponse;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.security.RequestClient;
import com.aloo.cms.service.ChatService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final RateLimitService rateLimitService;

    @PostMapping("/sessions")
    public ResponseEntity<ChatSessionResponse> createSession(
            @Valid @RequestBody ChatSessionCreateRequest request,
            HttpServletRequest httpRequest
    ) {
        rateLimitService.check("chat-session-create", RequestClient.ip(httpRequest), 10, Duration.ofMinutes(15));
        return ResponseEntity.status(HttpStatus.CREATED).body(chatService.createSession(request));
    }

    @PostMapping("/sessions/account")
    public ResponseEntity<ChatSessionResponse> createAccountSession(Authentication authentication) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(chatService.createSessionForAuthenticatedUser(authentication.getName()));
    }

    @GetMapping("/sessions/mine")
    public ChatSessionResponse getMySession(
            @RequestHeader("X-Chat-Token") String sessionToken,
            HttpServletRequest httpRequest
    ) {
        rateLimitService.check("chat-session-mine", RequestClient.ip(httpRequest), 60, Duration.ofMinutes(10));
        return chatService.getVisitorSession(sessionToken);
    }
}
