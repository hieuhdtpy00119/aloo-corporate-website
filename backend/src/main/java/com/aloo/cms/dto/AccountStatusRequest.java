package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;

public record AccountStatusRequest(
        @NotBlank(message = "Status is required")
        String status
) {
}