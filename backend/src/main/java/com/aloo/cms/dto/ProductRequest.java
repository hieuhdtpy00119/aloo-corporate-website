package com.aloo.cms.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record ProductRequest(
        @NotBlank(message = "Product name is required")
        @Size(max = 220, message = "Product name must be at most 220 characters")
        String name,

        @NotBlank(message = "Product slug is required")
        @Size(max = 240, message = "Product slug must be at most 240 characters")
        String slug,

        String description,

        String shortDescription,

        String detailContent,

        String ingredients,

        String tasteProfile,

        String servingSuggestion,

        String gallery,

        String faqs,

        @DecimalMin(value = "0.0", inclusive = true, message = "Price must be greater than or equal to 0")
        BigDecimal price,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        Long categoryId,

        @Size(max = 120, message = "Category must be at most 120 characters")
        String category,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        Boolean featured,

        @Size(max = 260, message = "SEO title must be at most 260 characters")
        String seoTitle,

        @Size(max = 500, message = "SEO description must be at most 500 characters")
        String seoDescription,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}

