package com.aloo.cms.dto;

public record CategoryResponse(
        Long id,
        String name,
        String slug,
        String type,
        String description,
        Long parentId,
        Integer sortOrder,
        String status,
        String languageCode
) {
}
