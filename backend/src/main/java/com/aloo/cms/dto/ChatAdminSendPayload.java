package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ChatAdminSendPayload(
        @NotNull(message = "Session id is required")
        Long sessionId,

        @NotBlank(message = "Message body is required")
        @Size(max = 4000, message = "Message must be at most 4000 characters")
        String body
) {
}
