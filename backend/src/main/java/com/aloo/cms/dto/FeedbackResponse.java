package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record FeedbackResponse(
        Long id,
        String customerName,
        String avatarUrl,
        String storeName,
        Integer rating,
        String content,
        Boolean visible,
        Integer sortOrder,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
