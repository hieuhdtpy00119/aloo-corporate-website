package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChatSessionCreateRequest(
        @NotBlank(message = "Visitor name is required")
        @Size(max = 180, message = "Visitor name must be at most 180 characters")
        String fullName,

        @NotBlank(message = "Phone is required")
        @Size(max = 40, message = "Phone must be at most 40 characters")
        String phone
) {
}
