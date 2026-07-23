package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record PromoteCustomerRequest(
        @NotBlank(message = "Admin profile is required")
        String adminProfile,
        @NotBlank(message = "Reason is required")
        String reason,
        @NotNull(message = "Expected version is required")
        Long expectedVersion
) {
}
