package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record HeroBannerRequest(
        @NotBlank(message = "Title is required")
        @Size(max = 220, message = "Title must be at most 220 characters")
        String title,

        @Size(max = 180, message = "Subtitle must be at most 180 characters")
        String subtitle,

        @Size(max = 1000, message = "Description must be at most 1000 characters")
        String description,

        @Size(max = 600, message = "Background image URL must be at most 600 characters")
        String backgroundImageUrl,

        @Size(max = 600, message = "Product image URL must be at most 600 characters")
        String productImageUrl,

        @Size(max = 600, message = "Thumbnail image URL must be at most 600 characters")
        String thumbnailImageUrl,

        @Size(max = 20, message = "Tone must be at most 20 characters")
        String tone,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
