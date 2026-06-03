package com.aloo.cms.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.oauth2.client.CommonOAuth2Provider;
import org.springframework.security.oauth2.client.InMemoryOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.InMemoryClientRegistrationRepository;

@Configuration
public class OAuth2ClientConfig {

    @Bean
    @ConditionalOnExpression("'${app.oauth2.google.client-id:}' != '' && '${app.oauth2.google.client-secret:}' != ''")
    public ClientRegistrationRepository clientRegistrationRepository(
            @Value("${app.oauth2.google.client-id}") String clientId,
            @Value("${app.oauth2.google.client-secret}") String clientSecret
    ) {
        ClientRegistration google = CommonOAuth2Provider.GOOGLE
                .getBuilder("google")
                .clientId(clientId)
                .clientSecret(clientSecret)
                .scope("openid", "email", "profile")
                .redirectUri("{baseUrl}/login/oauth2/code/{registrationId}")
                .build();

        return new InMemoryClientRegistrationRepository(google);
    }

    @Bean
    @ConditionalOnExpression("'${app.oauth2.google.client-id:}' != '' && '${app.oauth2.google.client-secret:}' != ''")
    public OAuth2AuthorizedClientService authorizedClientService(ClientRegistrationRepository registrations) {
        return new InMemoryOAuth2AuthorizedClientService(registrations);
    }
}
