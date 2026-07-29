package com.aloo.cms.service;

import com.aloo.cms.dto.PasswordChangeOtpResponse;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.support.PasswordChangePolicy;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class PasswordChangeOtpService {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int MAX_VERIFY_ATTEMPTS = 5;

    private final Map<Long, OtpEntry> otpStore = new ConcurrentHashMap<>();
    private final MailNotificationService mailNotificationService;
    private final RateLimitService rateLimitService;

    @Value("${app.password-change.otp.ttl-minutes:10}")
    private int ttlMinutes;

    public boolean isOtpRequired(AdminUser user) {
        return PasswordChangePolicy.requiresOtpVerification(user) && mailNotificationService.isMailEnabled();
    }

    public PasswordChangeOtpResponse requestOtp(AdminUser user) {
        if (!PasswordChangePolicy.requiresOtpVerification(user)) {
            throw new BadRequestException("Verification code is not required for this account");
        }
        if (!mailNotificationService.isMailEnabled()) {
            throw new BadRequestException("Email service is not configured");
        }

        rateLimitService.check(
                "password-change-otp",
                String.valueOf(user.getId()),
                3,
                Duration.ofMinutes(15)
        );

        String otp = generateOtp();
        Instant expiresAt = Instant.now().plus(Duration.ofMinutes(ttlMinutes));
        otpStore.put(user.getId(), new OtpEntry(hashOtp(otp), expiresAt, new AtomicInteger(0)));

        boolean sent = mailNotificationService.sendPasswordChangeOtp(user, otp);
        if (!sent) {
            otpStore.remove(user.getId());
            throw new BadRequestException("Could not send verification email");
        }

        return new PasswordChangeOtpResponse(
                PasswordChangePolicy.maskEmail(user.getEmail()),
                ttlMinutes * 60
        );
    }

    public void verifyAndConsume(Long userId, String otp) {
        String normalizedOtp = otp == null ? "" : otp.trim();
        if (!StringUtils.hasText(normalizedOtp)) {
            throw new BadRequestException("Verification code is required");
        }
        if (!normalizedOtp.matches("\\d{6}")) {
            throw new BadRequestException("Verification code must be 6 digits");
        }

        OtpEntry entry = otpStore.get(userId);
        if (entry == null || Instant.now().isAfter(entry.expiresAt())) {
            otpStore.remove(userId);
            throw new BadRequestException("Verification code expired or not requested");
        }

        if (entry.failedAttempts().get() >= MAX_VERIFY_ATTEMPTS) {
            otpStore.remove(userId);
            throw new BadRequestException("Too many incorrect verification attempts. Request a new code.");
        }

        if (!constantTimeEquals(hashOtp(normalizedOtp), entry.codeHash())) {
            int attempts = entry.failedAttempts().incrementAndGet();
            if (attempts >= MAX_VERIFY_ATTEMPTS) {
                otpStore.remove(userId);
                throw new BadRequestException("Too many incorrect verification attempts. Request a new code.");
            }
            throw new BadRequestException("Verification code is incorrect");
        }

        otpStore.remove(userId);
    }

    private String generateOtp() {
        int value = RANDOM.nextInt(1_000_000);
        return String.format("%06d", value);
    }

    private String hashOtp(String otp) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(otp.getBytes()));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }

    private boolean constantTimeEquals(String left, String right) {
        return MessageDigest.isEqual(left.getBytes(), right.getBytes());
    }

    private record OtpEntry(String codeHash, Instant expiresAt, AtomicInteger failedAttempts) {
    }
}
