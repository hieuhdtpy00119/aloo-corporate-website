package com.aloo.cms.dto;

import java.time.LocalDateTime;
import java.util.List;

public record LocationResponse(
        Long id,
        String name,
        String address,
        String addressText,
        String province,
        String city,
        String district,
        String phone,
        String openingHours,
        String mapUrl,
        String imageUrl,
        List<String> amenities,
        Integer displayOrder,
        Boolean featured,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
