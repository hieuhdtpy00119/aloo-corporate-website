package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record ProductReviewStatusUpdateRequest(
        @NotBlank(message = "Status is required")
        @Pattern(regexp = "APPROVED|REJECTED", message = "Status must be APPROVED or REJECTED")
        String status
) {
}
