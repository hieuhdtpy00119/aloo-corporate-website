package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record HeroBannerResponse(
        Long id,
        String title,
        String subtitle,
        String description,
        String backgroundImageUrl,
        String productImageUrl,
        String thumbnailImageUrl,
        String tone,
        Integer sortOrder,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
