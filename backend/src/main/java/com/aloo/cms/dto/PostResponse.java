package com.aloo.cms.dto;

import java.time.LocalDateTime;
import java.util.List;

public record PostResponse(
        Long id,
        String title,
        String slug,
        String excerpt,
        String content,
        String thumbnailUrl,
        Long categoryId,
        String category,
        String author,
        String source,
        String sourceLink,
        String articleType,
        String status,
        LocalDateTime publishedAt,
        String seoTitle,
        String seoDescription,
        String metaKeywords,
        String metaDescription,
        String canonicalUrl,
        List<String> tags,
        List<String> gallery,
        List<Long> relatedPostIds,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
