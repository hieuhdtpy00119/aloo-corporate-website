package com.aloo.cms.mapper;

import java.util.Locale;

final class MapperUtils {

    private MapperUtils() {
    }

    static String required(String value) {
        return value.trim();
    }

    static String nullable(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    static String slug(String value) {
        return required(value).toLowerCase(Locale.ROOT);
    }

    static String status(String value, String defaultValue) {
        String normalized = nullable(value);
        return normalized == null ? defaultValue : normalized.toUpperCase(Locale.ROOT);
    }
}
