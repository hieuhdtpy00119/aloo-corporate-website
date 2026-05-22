package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record FranchiseContentRequest(
        @NotBlank(message = "Section key is required")
        @Size(max = 120, message = "Section key must be at most 120 characters")
        String sectionKey,

        @NotBlank(message = "Title is required")
        @Size(max = 220, message = "Title must be at most 220 characters")
        String title,

        String content,

        @Size(max = 120, message = "Amount must be at most 120 characters")
        String amount,

        String note,

        @NotNull(message = "Sort order is required")
        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
