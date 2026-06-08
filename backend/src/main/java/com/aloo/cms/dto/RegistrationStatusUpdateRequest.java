package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegistrationStatusUpdateRequest(
        @NotBlank(message = "Status is required")
        @Size(max = 40, message = "Status must be at most 40 characters")
        String status,

        String note,

        String lastContactedAt,

        @Size(max = 180, message = "Assigned admin must be at most 180 characters")
        String assignedTo
) {
    public RegistrationStatusUpdateRequest(String status) {
        this(status, null, null, null);
    }
}
