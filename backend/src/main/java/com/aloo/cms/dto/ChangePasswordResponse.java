package com.aloo.cms.dto;

import java.time.LocalDateTime;

public record ChangePasswordResponse(
        LocalDateTime passwordChangedAt,
        boolean emailNotificationSent
) {
}
