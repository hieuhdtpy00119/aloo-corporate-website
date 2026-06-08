package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record StoreRequest(
        @NotBlank(message = "Store code is required")
        @Size(max = 50, message = "Store code must be at most 50 characters")
        String storeCode,

        @NotBlank(message = "Store name is required")
        @Size(max = 180, message = "Store name must be at most 180 characters")
        String name,

        @NotBlank(message = "Slug is required")
        @Size(max = 220, message = "Slug must be at most 220 characters")
        String slug,

        @NotBlank(message = "Address is required")
        @Size(max = 500, message = "Address must be at most 500 characters")
        String address,

        @NotBlank(message = "Province is required")
        @Size(max = 120, message = "Province must be at most 120 characters")
        String province,

        @Size(max = 120, message = "District must be at most 120 characters")
        String district,

        @Size(max = 120, message = "Ward must be at most 120 characters")
        String ward,

        BigDecimal latitude,

        BigDecimal longitude,

        @Size(max = 80, message = "Phone must be at most 80 characters")
        String phone,

        @Size(max = 180, message = "Email must be at most 180 characters")
        String email,

        @Size(max = 255, message = "Opening hours must be at most 255 characters")
        String openingHours,

        @Size(max = 600, message = "Google Map URL must be at most 600 characters")
        String googleMapUrl,

        @Size(max = 40, message = "Store type must be at most 40 characters")
        String storeType,

        String description,

        @Size(max = 600, message = "Cover image URL must be at most 600 characters")
        String coverImageUrl,

        String galleryJson,

        String amenitiesJson,

        String menuPostersJson,

        String linksJson,

        Boolean featured,

        @Min(value = 0, message = "Display order must be greater than or equal to 0")
        Integer displayOrder,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
