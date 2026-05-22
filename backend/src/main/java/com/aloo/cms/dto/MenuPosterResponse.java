package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record MenuPosterResponse(
        Long id,
        String branchKey,
        String title,
        String subtitle,
        String imageUrl,
        String altText,
        Integer sortOrder,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
