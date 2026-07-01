package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;

public record PromoteCustomerRequest(
        @NotBlank(message = "Admin profile is required")
        String adminProfile
) {
}
