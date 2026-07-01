package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record ProductReviewResponse(
        Long id,
        Long productId,
        String productName,
        Long userId,
        String customerName,
        String avatarUrl,
        Integer rating,
        String content,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
