package com.aloo.cms.security;

import com.aloo.cms.dto.AuthResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

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

            String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                    .queryParam("token", auth.token())
                    .queryParam("role", auth.user().role())
                    .queryParam("user", userEncoded)
                    .build(true)
                    .toUriString();

            response.sendRedirect(targetUrl);
        } catch (Exception ex) {
            String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                    .queryParam("error", ex.getMessage() == null ? "Không thể đăng nhập bằng Google" : ex.getMessage())
                    .build(true)
                    .toUriString();

            response.sendRedirect(targetUrl);
        }
    }
}
