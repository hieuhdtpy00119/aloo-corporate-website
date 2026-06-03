package com.aloo.cms.controller;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.util.UriComponentsBuilder;

@Controller
@ConditionalOnMissingBean(ClientRegistrationRepository.class)
public class OAuth2UnavailableController {

    @Value("${app.oauth2.redirect-uri:http://localhost:5173/oauth/callback}")
    private String redirectUri;

    @GetMapping("/oauth2/authorization/google")
    public void googleUnavailable(HttpServletResponse response) throws IOException {
        String targetUrl = UriComponentsBuilder.fromUriString(redirectUri)
                .queryParam("error", "Google login chưa được cấu hình")
                .encode(StandardCharsets.UTF_8)
                .build()
                .toUriString();

        response.sendRedirect(targetUrl);
    }
}
