package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record ChatMessageResponse(
        Long id,
        Long sessionId,
        String senderType,
        Long senderAdminId,
        String senderName,
        String body,
        LocalDateTime readAt,
        LocalDateTime createdAt
) {
}
