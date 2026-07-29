package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record DemoteAdminRequest(
        @NotBlank(message = "Reason is required")
        String reason,
        Long transferToAdminId,
        @NotNull(message = "Expected version is required")
        Long expectedVersion
) {
}
