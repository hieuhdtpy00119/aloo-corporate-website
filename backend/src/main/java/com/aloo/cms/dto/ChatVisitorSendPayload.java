package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ChatVisitorSendPayload(
        @NotBlank(message = "Session token is required")
        String sessionToken,

        @NotBlank(message = "Message body is required")
        @Size(max = 4000, message = "Message must be at most 4000 characters")
        String body
) {
}
