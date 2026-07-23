package com.aloo.cms.security;

import com.aloo.cms.dto.AuthResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriUtils;

@Component
@RequiredArgsConstructor
public class OAuth2LoginSuccessHandler implements AuthenticationSuccessHandler {

    private final GoogleOAuthLoginService googleOAuthLoginService;
    private final ObjectMapper objectMapper;

    @Value("${app.oauth2.redirect-uri:http://localhost:5173/oauth/callback}")
    private String redirectUri;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException, ServletException {
        try {
            OAuth2AuthenticationToken oauthToken = (OAuth2AuthenticationToken) authentication;
            AuthResponse auth = googleOAuthLoginService.login(oauthToken.getPrincipal());

            String userJson = objectMapper.writeValueAsString(auth.user());
            String userEncoded = Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(userJson.getBytes(StandardCharsets.UTF_8));

            // Put credentials in the URL fragment so they are not sent to servers/proxies as query params.
            String fragment = "token=" + UriUtils.encodeQueryParam(auth.token(), StandardCharsets.UTF_8)
                    + "&role=" + UriUtils.encodeQueryParam(auth.user().role(), StandardCharsets.UTF_8)
                    + "&user=" + UriUtils.encodeQueryParam(userEncoded, StandardCharsets.UTF_8);

            String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                    .fragment(fragment)
                    .build(true)
                    .toUriString();

            clearServerSession(request);
            response.sendRedirect(targetUrl);
        } catch (Exception ex) {
            clearServerSession(request);
            String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                    .queryParam("error", ex.getMessage() == null ? "Không thể đăng nhập bằng Google" : ex.getMessage())
                    .build()
                    .encode()
                    .toUriString();

            response.sendRedirect(targetUrl);
        }
    }

    private void clearServerSession(HttpServletRequest request) {
        SecurityContextHolder.clearContext();
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}
