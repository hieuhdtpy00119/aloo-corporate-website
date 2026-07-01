package com.aloo.cms.dto;

import java.time.LocalDateTime;
import java.util.List;

public record ChatSessionResponse(
        Long id,
        String sessionToken,
        String visitorName,
        String visitorPhone,
        String status,
        Long assignedAdminId,
        LocalDateTime lastMessageAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        long unreadCount,
        List<ChatMessageResponse> messages
) {
}
