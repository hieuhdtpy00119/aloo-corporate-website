package com.aloo.cms.service;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;
import com.aloo.cms.exception.BadRequestException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class AdminEmailWhitelistService {

    private final Set<String> allowedEmails;
    private final boolean requireWhitelist;

    public AdminEmailWhitelistService(
            @Value("${app.admin.email-whitelist:}") String rawWhitelist,
            @Value("${app.admin.require-email-whitelist:true}") boolean requireWhitelist
    ) {
        this.allowedEmails = parse(rawWhitelist);
        this.requireWhitelist = requireWhitelist;
    }

    public boolean isEnabled() {
        return !allowedEmails.isEmpty();
    }

    public boolean isAllowed(String email) {
        if (!isEnabled()) {
            return !requireWhitelist;
        }
        String normalized = normalize(email);
        return normalized != null && allowedEmails.contains(normalized);
    }

    public List<String> getAllowedEmails() {
        return allowedEmails.stream().sorted().toList();
    }

    public void ensureAllowed(String email) {
        if (!isAllowed(email)) {
            throw new BadRequestException(
                    "This email is not on the admin whitelist. Contact a system administrator."
            );
        }
    }

    private Set<String> parse(String rawWhitelist) {
        if (rawWhitelist == null || rawWhitelist.isBlank()) {
            return Set.of();
        }
        return Arrays.stream(rawWhitelist.split("[,;\\s]+"))
                .map(this::normalize)
                .filter(value -> value != null && !value.isBlank())
                .collect(Collectors.toUnmodifiableSet());
    }

    private String normalize(String email) {
        if (email == null) {
            return null;
        }
        String trimmed = email.trim().toLowerCase(Locale.ROOT);
        return trimmed.isEmpty() ? null : trimmed;
    }
}
