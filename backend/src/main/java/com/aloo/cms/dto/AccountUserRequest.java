package com.aloo.cms.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AccountUserRequest(
        @NotBlank(message = "Email is required")
        @Email(message = "Email is invalid")
        @Size(max = 180, message = "Email must be at most 180 characters")
        String email,

        @NotBlank(message = "Full name is required")
        @Size(max = 180, message = "Full name must be at most 180 characters")
        String fullName,

        @Size(max = 40, message = "Phone must be at most 40 characters")
        String phone,

        @Size(max = 600, message = "Avatar URL must be at most 600 characters")
        String avatarUrl,

        @Size(min = 8, max = 120, message = "Password must be from 8 to 120 characters")
        String password,

        String status,

        String adminProfile
) {
}