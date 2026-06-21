package com.aloo.cms.dto;

import java.time.LocalDateTime;
import java.util.List;

public record UserResponse(
        Long id,
        String email,
        String fullName,
        String phone,
        String avatarUrl,
        String role,
        String adminProfile,
        List<String> scopes,
        String status,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
