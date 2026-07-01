package com.aloo.cms.dto;

import java.time.LocalDateTime;
import java.util.List;

public record AccountUserResponse(
        Long id,
        String email,
        String fullName,
        String phone,
        String avatarUrl,
        String role,
        String adminProfile,
        List<String> scopes,
        String status,
        String authProvider,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
