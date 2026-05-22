package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record MenuPosterRequest(
        @NotBlank(message = "Branch key is required")
        @Size(max = 120, message = "Branch key must be at most 120 characters")
        String branchKey,

        @NotBlank(message = "Title is required")
        @Size(max = 220, message = "Title must be at most 220 characters")
        String title,

        @Size(max = 180, message = "Subtitle must be at most 180 characters")
        String subtitle,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        @Size(max = 260, message = "Alt text must be at most 260 characters")
        String altText,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
