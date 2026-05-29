package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record HomeSectionResponse(
        Long id,
        String sectionKey,
        String type,
        String title,
        String subtitle,
        String description,
        String imageUrl,
        String buttonText,
        String buttonLink,
        String badge,
        Integer sortOrder,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
