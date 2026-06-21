package com.aloo.cms.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

@Component
public class OAuth2LoginFailureHandler implements AuthenticationFailureHandler {

    @Value("${app.oauth2.redirect-uri:http://localhost:5173/oauth/callback}")
    private String redirectUri;

    @Override
    public void onAuthenticationFailure(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException exception
    ) throws IOException, ServletException {
        String message = exception.getMessage() == null || exception.getMessage().isBlank()
                ? "Không thể đăng nhập bằng Google"
                : exception.getMessage();

        String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                .queryParam("error", message)
                .build(true)
                .toUriString();

        response.sendRedirect(targetUrl);
    }
}
