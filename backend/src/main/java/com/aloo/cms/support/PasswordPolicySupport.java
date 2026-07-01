package com.aloo.cms.support;

import com.aloo.cms.exception.BadRequestException;
import java.util.regex.Pattern;

public final class PasswordPolicySupport {

    private static final int MIN_LENGTH = 8;
    private static final Pattern UPPER = Pattern.compile("[A-Z]");
    private static final Pattern LOWER = Pattern.compile("[a-z]");
    private static final Pattern DIGIT = Pattern.compile("\\d");
    private static final Pattern SPECIAL = Pattern.compile("[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~]");

    private PasswordPolicySupport() {
    }

    public static void validateStrongPassword(String password) {
        if (password == null || password.length() < MIN_LENGTH) {
            throw new BadRequestException("Password must be at least 8 characters");
        }
        if (!UPPER.matcher(password).find()) {
            throw new BadRequestException("Password must include an uppercase letter");
        }
        if (!LOWER.matcher(password).find()) {
            throw new BadRequestException("Password must include a lowercase letter");
        }
        if (!DIGIT.matcher(password).find()) {
            throw new BadRequestException("Password must include a number");
        }
        if (!SPECIAL.matcher(password).find()) {
            throw new BadRequestException("Password must include a special character");
        }
    }
}
