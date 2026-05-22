package com.aloo.cms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public record LocationRequest(
        @NotBlank(message = "Location name is required")
        @Size(max = 180, message = "Location name must be at most 180 characters")
        String name,

        @NotBlank(message = "Address is required")
        @Size(max = 500, message = "Address must be at most 500 characters")
        String address,

        @NotBlank(message = "Province is required")
        @Size(max = 120, message = "Province must be at most 120 characters")
        String province,

        @Size(max = 120, message = "District must be at most 120 characters")
        String district,

        @Size(max = 40, message = "Phone must be at most 40 characters")
        String phone,

        @Size(max = 180, message = "Opening hours must be at most 180 characters")
        String openingHours,

        @Size(max = 1000, message = "Map URL must be at most 1000 characters")
        String mapUrl,

        @Size(max = 600, message = "Image URL must be at most 600 characters")
        String imageUrl,

        List<String> amenities,

        @Min(value = 0, message = "Display order must be greater than or equal to 0")
        Integer displayOrder,

        Boolean featured,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status
) {
}
