package com.aloo.cms.entity;

import java.util.List;

public enum AdminProfile {
    FULL(List.of("dashboard", "content", "stores", "crm", "system")),
    CONTENT(List.of("dashboard", "content")),
    STORES(List.of("dashboard", "stores", "crm")),
    CRM(List.of("dashboard", "crm")),
    SYSTEM(List.of("dashboard", "system"));

    private final List<String> scopes;

    AdminProfile(List<String> scopes) {
        this.scopes = scopes;
    }

    public List<String> scopes() {
        return scopes;
    }
}
