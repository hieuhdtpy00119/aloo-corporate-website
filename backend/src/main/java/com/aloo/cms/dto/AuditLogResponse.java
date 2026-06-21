package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record AuditLogResponse(
        Long id,
        String actorEmail,
        String action,
        String entityType,
        String entityId,
        String details,
        LocalDateTime createdAt
) {
}
