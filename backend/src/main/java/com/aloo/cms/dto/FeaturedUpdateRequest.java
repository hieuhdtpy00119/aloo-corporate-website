package com.aloo.cms.dto;

import jakarta.validation.constraints.NotNull;

public record FeaturedUpdateRequest(
        @NotNull(message = "Featured value is required")
        Boolean featured
) {
}
