package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record HomeSectionRequest(
        @NotBlank(message = "Section key is required")
        @Size(max = 120, message = "Section key must be at most 120 characters")
        String sectionKey,

        @Size(max = 60, message = "Type must be at most 60 characters")
        String type,

        @NotBlank(message = "Title is required")
        @Size(max = 220, message = "Title must be at most 220 characters")
        String title,

        @Size(max = 180, message = "Subtitle must be at most 180 characters")
        String subtitle,

        String description,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        @Size(max = 120, message = "Button text must be at most 120 characters")
        String buttonText,

        @Size(max = 600, message = "Button link must be at most 600 characters")
        String buttonLink,

        @Size(max = 160, message = "Badge must be at most 160 characters")
        String badge,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
