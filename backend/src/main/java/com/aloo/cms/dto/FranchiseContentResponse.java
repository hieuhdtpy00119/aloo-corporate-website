package com.aloo.cms.dto;

public record FranchiseContentResponse(
        Long id,
        String sectionKey,
        String title,
        String content,
        String amount,
        String note,
        Integer sortOrder,
        String status
) {
}
