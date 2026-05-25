package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record AccountUserResponse(
        Long id,
        String email,
        String fullName,
        String phone,
        String avatarUrl,
        String role,
        String status,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}