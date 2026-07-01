package com.aloo.cms.dto;

import java.util.List;

public record AdminEmailWhitelistResponse(
        boolean enabled,
        List<String> emails
) {
}
