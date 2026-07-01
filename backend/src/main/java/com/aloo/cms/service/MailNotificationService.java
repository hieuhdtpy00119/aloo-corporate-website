package com.aloo.cms.service;

import com.aloo.cms.entity.AdminUser;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@Slf4j
public class MailNotificationService {

    private static final DateTimeFormatter DISPLAY_FORMAT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final JavaMailSender mailSender;

    @Value("${app.mail.enabled:false}")
    private boolean mailEnabled;

    @Value("${app.mail.from:noreply@aloo.vn}")
    private String fromAddress;

    public MailNotificationService(@Autowired(required = false) JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public boolean isMailEnabled() {
        return mailEnabled && mailSender != null && StringUtils.hasText(fromAddress);
    }

    public boolean sendPasswordChangeOtp(AdminUser user, String otp) {
        if (!isMailEnabled()) {
            log.debug("Mail disabled or not configured; skip password OTP for {}", user.getEmail());
            return false;
        }

        String recipient = user.getEmail();
        if (!StringUtils.hasText(recipient)) {
            return false;
        }

        String displayName = StringUtils.hasText(user.getFullName()) ? user.getFullName() : recipient;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(recipient);
        message.setSubject("[ALOO] Mã xác nhận đặt mật khẩu");
        message.setText("""
                Xin chào %s,

                Mã xác nhận đặt mật khẩu ALOO của bạn là: %s

                Mã có hiệu lực trong 10 phút. Không chia sẻ mã này với bất kỳ ai.

                Nếu bạn không yêu cầu đặt mật khẩu, hãy bỏ qua email này.

                Trân trọng,
                ALOO
                """.formatted(displayName, otp));

        try {
            mailSender.send(message);
            return true;
        } catch (Exception ex) {
            log.warn("Failed to send password OTP to {}", recipient, ex);
            return false;
        }
    }

    public boolean sendPasswordChangedNotification(AdminUser user, LocalDateTime changedAt) {
        if (!isMailEnabled()) {
            log.debug("Mail disabled or not configured; skip password notification for {}", user.getEmail());
            return false;
        }

        String recipient = user.getEmail();
        if (!StringUtils.hasText(recipient)) {
            return false;
        }

        String changedLabel = changedAt == null ? "-" : changedAt.format(DISPLAY_FORMAT);
        String displayName = StringUtils.hasText(user.getFullName()) ? user.getFullName() : recipient;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(recipient);
        message.setSubject("[ALOO] Mật khẩu tài khoản đã được thay đổi");
        message.setText("""
                Xin chào %s,

                Mật khẩu tài khoản ALOO của bạn vừa được thay đổi lúc %s (giờ Việt Nam).

                Email tài khoản: %s

                Nếu bạn không thực hiện thay đổi này, hãy liên hệ ngay bộ phận hỗ trợ ALOO.

                Trân trọng,
                ALOO
                """.formatted(displayName, changedLabel, recipient));

        try {
            mailSender.send(message);
            return true;
        } catch (Exception ex) {
            log.warn("Failed to send password change notification to {}", recipient, ex);
            return false;
        }
    }
}
