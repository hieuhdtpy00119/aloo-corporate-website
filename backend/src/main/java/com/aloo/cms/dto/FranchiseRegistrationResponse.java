package com.aloo.cms.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FranchiseRegistrationResponse(
        Long id,
        String fullName,
        String phone,
        String email,
        String province,
        BigDecimal expectedBudget,
        String note,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
