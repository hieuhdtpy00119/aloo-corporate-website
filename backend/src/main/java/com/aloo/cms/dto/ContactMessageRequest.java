package com.aloo.cms.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ContactMessageRequest(
        @NotBlank(message = "Full name is required")
        @Size(max = 180, message = "Full name must be at most 180 characters")
        String fullName,

        @Email(message = "Email is invalid")
        @Size(max = 180, message = "Email must be at most 180 characters")
        String email,

        @NotBlank(message = "Phone is required")
        @Size(max = 40, message = "Phone must be at most 40 characters")
        String phone,

        @Size(max = 220, message = "Subject must be at most 220 characters")
        String subject,

        @NotBlank(message = "Message is required")
        String message,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
