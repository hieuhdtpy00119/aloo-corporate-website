package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(
        String currentPassword,

        String otp,

        @NotBlank(message = "New password is required")
        @Size(min = 8, max = 120, message = "New password must be between 8 and 120 characters")
        String newPassword
) {
}
