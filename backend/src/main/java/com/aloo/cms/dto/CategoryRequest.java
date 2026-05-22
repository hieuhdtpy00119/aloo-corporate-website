package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

public record CategoryRequest(
        @NotBlank(message = "Category name is required")
        @Size(max = 180, message = "Category name must be at most 180 characters")
        String name,

        @NotBlank(message = "Category slug is required")
        @Size(max = 220, message = "Category slug must be at most 220 characters")
        String slug,

        @Size(max = 30, message = "Category type must be at most 30 characters")
        String type,

        @Size(max = 1000, message = "Description must be at most 1000 characters")
        String description,

        Long parentId,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status,

        @Size(max = 10, message = "Language code must be at most 10 characters")
        String languageCode
) {
}
