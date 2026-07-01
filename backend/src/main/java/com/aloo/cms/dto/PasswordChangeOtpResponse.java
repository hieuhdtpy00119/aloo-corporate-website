package com.aloo.cms.dto;

public record PasswordChangeOtpResponse(
        String maskedEmail,
        int expiresInSeconds
) {
}
