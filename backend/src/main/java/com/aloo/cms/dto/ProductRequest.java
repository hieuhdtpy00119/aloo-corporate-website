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

        @DecimalMin(value = "0.0", inclusive = true, message = "Price must be greater than or equal to 0")
        BigDecimal price,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        Long categoryId,

        @Size(max = 120, message = "Category must be at most 120 characters")
        String category,

        @Min(value = 0, message = "Sort order must be greater than or equal to 0")
        Integer sortOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
