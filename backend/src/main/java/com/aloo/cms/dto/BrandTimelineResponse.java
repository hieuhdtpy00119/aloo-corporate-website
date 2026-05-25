package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record BrandTimelineResponse(
        Long id,
        String year,
        String title,
        String description,
        String imageUrl,
        Integer sortOrder,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
