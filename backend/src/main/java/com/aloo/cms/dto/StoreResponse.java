package com.aloo.cms.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public record StoreResponse(
        Long id,
        String storeCode,
        String name,
        String slug,
        String address,
        String addressText,
        String province,
        String city,
        String district,
        String ward,
        BigDecimal latitude,
        BigDecimal longitude,
        String phone,
        String email,
        String openingHours,
        String googleMapUrl,
        String storeType,
        String description,
        String coverImageUrl,
        String imageUrl,
        String galleryJson,
        String amenitiesJson,
        String menuPostersJson,
        String linksJson,
        String mapUrl,
        List<String> amenities,
        List<Map<String, Object>> links,
        List<Map<String, Object>> gallery,
        List<Map<String, Object>> businessHours,
        List<Map<String, Object>> menuPosters,
        Boolean featured,
        Integer displayOrder,
        String status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
