package com.aloo.cms.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record FeedbackRequest(
        @NotBlank(message = "Customer name is required")
        @Size(max = 100, message = "Customer name must be at most 100 characters")
        String customerName,

        @Size(max = 500, message = "Avatar URL must be at most 500 characters")
        String avatarUrl,

        @NotNull(message = "Rating is required")
        @Min(value = 1, message = "Rating must be at least 1")
        @Max(value = 5, message = "Rating must be at most 5")
        Integer rating,

        @NotBlank(message = "Content is required")
        String content,

        @Size(max = 180, message = "Store name must be at most 180 characters")
        String storeName,

        Boolean visible,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder
) {
}
