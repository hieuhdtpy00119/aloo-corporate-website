package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record ContactMessageResponse(
        Long id,
        String fullName,
        String email,
        String phone,
        String subject,
        String message,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
