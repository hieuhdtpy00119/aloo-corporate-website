package com.aloo.cms.exception;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void lockedAccountReturnsUnauthorizedInsteadOfServerError() {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/auth/login");

        var response = handler.handleLockedAccount(new LockedException("Locked"), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Account is locked");
    }

    @Test
    void inactiveAccountReturnsUnauthorizedInsteadOfServerError() {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/auth/login");

        var response = handler.handleDisabledAccount(new DisabledException("Disabled"), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Account is inactive");
    }

    @Test
    void oversizedUploadReturnsPayloadTooLargeInsteadOfServerError() {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/uploads/images");

        var response = handler.handleMaxUploadSize(new MaxUploadSizeExceededException(5_242_880), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.PAYLOAD_TOO_LARGE);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().message()).isEqualTo("Image file exceeds the 5 MB upload limit");
    }
}
