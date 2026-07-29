package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AccountStatusRequest(
        @NotBlank(message = "Status is required")
        String status,
        @NotBlank(message = "Reason is required")
        String reason,
        @NotNull(message = "Expected version is required")
        Long expectedVersion
) {
}
