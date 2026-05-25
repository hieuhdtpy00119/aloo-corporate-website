package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record BrandTimelineRequest(
        @NotBlank(message = "Year is required")
        @Size(max = 80, message = "Year must be at most 80 characters")
        String year,

        @NotBlank(message = "Title is required")
        @Size(max = 220, message = "Title must be at most 220 characters")
        String title,

        String description,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
