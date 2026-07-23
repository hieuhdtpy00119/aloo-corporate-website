package com.aloo.cms.dto;

import java.util.List;

public record AccountPageResponse(
        List<AccountUserResponse> items,
        long totalElements,
        int totalPages,
        int page,
        int size
) {
}
