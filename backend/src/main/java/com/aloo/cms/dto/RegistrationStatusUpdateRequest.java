package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegistrationStatusUpdateRequest(
        @NotBlank(message = "Status is required")
        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
