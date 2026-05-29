package com.aloo.cms.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ProductResponse(
        Long id,
        String name,
        String slug,
        String description,
        String shortDescription,
        String detailContent,
        String ingredients,
        String tasteProfile,
        String servingSuggestion,
        String gallery,
        String faqs,
        BigDecimal price,
        String imageUrl,
        Long categoryId,
        String category,
        Integer sortOrder,
        Boolean featured,
        String seoTitle,
        String seoDescription,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}

