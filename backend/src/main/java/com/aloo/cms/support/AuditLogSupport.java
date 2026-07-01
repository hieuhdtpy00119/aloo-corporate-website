package com.aloo.cms.support;

import java.util.Locale;

public final class AuditLogSupport {

    private AuditLogSupport() {
    }

    public static String kindLabel(String entityType) {
        if (entityType == null || entityType.isBlank()) {
            return "item";
        }
        return entityType.toLowerCase(Locale.ROOT).replace('_', ' ');
    }

    public static String created(String entityType, String name, String reference) {
        return "Created " + kindLabel(entityType) + " \"" + safe(name) + "\" (" + safe(reference) + ")";
    }

    public static String updated(String entityType, String name, String reference) {
        return "Updated " + kindLabel(entityType) + " \"" + safe(name) + "\" (" + safe(reference) + ")";
    }

    public static String deleted(String entityType, String name, String reference) {
        return "Deleted " + kindLabel(entityType) + " \"" + safe(name) + "\" (" + safe(reference) + ")";
    }

    public static String statusChanged(String entityType, String name, String status) {
        return "Changed status of " + kindLabel(entityType) + " \"" + safe(name) + "\" to " + safe(status);
    }

    public static String featuredChanged(String entityType, String name, boolean featured) {
        return "Changed featured flag of " + kindLabel(entityType) + " \"" + safe(name) + "\" to " + featured;
    }

    public static String uploaded(String fileName) {
        return "Uploaded file \"" + safe(fileName) + "\"";
    }

    private static String safe(String value) {
        return value == null ? "" : value.replace("\"", "'");
    }
}
