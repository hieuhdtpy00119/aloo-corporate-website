package com.aloo.cms.dto;

import java.util.List;

public record AuditLogPageResponse(
        List<AuditLogResponse> items,
        long totalElements,
        int totalPages,
        int page,
        int size
) {}
