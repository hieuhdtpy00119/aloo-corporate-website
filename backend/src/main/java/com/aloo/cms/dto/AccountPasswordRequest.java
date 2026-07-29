package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AccountPasswordRequest(
        @NotBlank(message = "Password is required")
        @Size(min = 8, max = 120, message = "Password must be from 8 to 120 characters")
        String password
) {
}
