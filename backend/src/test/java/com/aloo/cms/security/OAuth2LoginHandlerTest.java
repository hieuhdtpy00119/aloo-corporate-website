package com.aloo.cms.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.UserResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockHttpSession;

class OAuth2LoginHandlerTest {

    @Test
    void failureHandlerEncodesOAuthErrorInRedirect() throws Exception {
        OAuth2LoginFailureHandler handler = new OAuth2LoginFailureHandler();
        ReflectionTestUtils.setField(handler, "redirectUri", "http://localhost:5173/oauth/callback");
        MockHttpServletResponse response = new MockHttpServletResponse();
        OAuth2AuthenticationException exception = new OAuth2AuthenticationException(
                new OAuth2Error("invalid_id_token"),
                "[invalid_id_token] The ID Token contains invalid claims: {iat=2026-07-16T11:54:42Z}"
        );

        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpSession session = (MockHttpSession) request.getSession();
        handler.onAuthenticationFailure(request, response, exception);

        assertThat(response.getRedirectedUrl())
                .isEqualTo("http://localhost:5173/oauth/callback?error=%5Binvalid_id_token%5D%20The%20ID%20Token%20contains%20invalid%20claims:%20%7Biat%3D2026-07-16T11:54:42Z%7D");
        assertThat(session.isInvalid()).isTrue();
    }

    @Test
    void successHandlerEncodesServiceErrorInRedirect() throws Exception {
        GoogleOAuthLoginService loginService = mock(GoogleOAuthLoginService.class);
        OAuth2AuthenticationToken authentication = mock(OAuth2AuthenticationToken.class);
        when(loginService.login(authentication.getPrincipal()))
                .thenThrow(new IllegalStateException("Account [blocked] / try again"));

        OAuth2LoginSuccessHandler handler = new OAuth2LoginSuccessHandler(loginService, new ObjectMapper());
        ReflectionTestUtils.setField(handler, "redirectUri", "http://localhost:5173/oauth/callback");
        MockHttpServletResponse response = new MockHttpServletResponse();

        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpSession session = (MockHttpSession) request.getSession();
        handler.onAuthenticationSuccess(request, response, authentication);

        assertThat(response.getRedirectedUrl())
                .isEqualTo("http://localhost:5173/oauth/callback?error=Account%20%5Bblocked%5D%20/%20try%20again");
        assertThat(session.isInvalid()).isTrue();
    }

    @Test
    void successHandlerInvalidatesOAuthSessionAfterIssuingJwt() throws Exception {
        GoogleOAuthLoginService loginService = mock(GoogleOAuthLoginService.class);
        OAuth2AuthenticationToken authentication = mock(OAuth2AuthenticationToken.class);
        UserResponse user = new UserResponse(
                1L, "user@aloo.vn", "User", null, null, "USER", null, List.of(),
                "ACTIVE", "GOOGLE", false, false, null, null, null, null
        );
        when(loginService.login(authentication.getPrincipal())).thenReturn(AuthResponse.bearer("jwt-token", user));

        OAuth2LoginSuccessHandler handler = new OAuth2LoginSuccessHandler(loginService, new ObjectMapper());
        ReflectionTestUtils.setField(handler, "redirectUri", "http://localhost:5173/oauth/callback");
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpSession session = (MockHttpSession) request.getSession();
        MockHttpServletResponse response = new MockHttpServletResponse();

        handler.onAuthenticationSuccess(request, response, authentication);

        String redirected = response.getRedirectedUrl();
        assertThat(redirected).startsWith("http://localhost:5173/oauth/callback#");
        assertThat(redirected).contains("token=jwt-token");
        assertThat(redirected).doesNotContain("?token=");
        assertThat(session.isInvalid()).isTrue();
    }
}
