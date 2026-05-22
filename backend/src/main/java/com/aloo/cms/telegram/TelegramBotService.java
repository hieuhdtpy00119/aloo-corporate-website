package com.aloo.cms.telegram;

import com.aloo.cms.entity.FranchiseRegistration;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
public class TelegramBotService {

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    private final RestTemplate restTemplate;

    @Value("${telegram.bot.token}")
    private String botToken;

    @Value("${telegram.chat.id}")
    private String chatId;

    public TelegramBotService(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder
                .setConnectTimeout(Duration.ofSeconds(3))
                .setReadTimeout(Duration.ofSeconds(5))
                .build();
    }

    public void notifyNewRegistration(FranchiseRegistration registration) {
        if (!StringUtils.hasText(botToken) || !StringUtils.hasText(chatId)) {
            log.warn("Telegram notification skipped because telegram.bot.token or telegram.chat.id is empty");
            return;
        }

        String url = "https://api.telegram.org/bot%s/sendMessage".formatted(botToken);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, String> payload = Map.of(
                "chat_id", chatId,
                "text", buildMessage(registration)
        );

        try {
            restTemplate.postForEntity(url, new HttpEntity<>(payload, headers), String.class);
        } catch (RestClientException ex) {
            log.warn("Telegram notification failed: {}", ex.getMessage());
        }
    }

    private String buildMessage(FranchiseRegistration registration) {
        return """
                🚀 ALOO có đăng ký tư vấn mới!
                👤 Họ tên: %s
                📞 SĐT: %s
                📧 Email: %s
                📍 Khu vực: %s
                💰 Số vốn: %s
                📝 Ghi chú: %s
                🕒 Thời gian: %s
                """.formatted(
                value(registration.getFullName()),
                value(registration.getPhone()),
                value(registration.getEmail()),
                value(registration.getProvince()),
                budget(registration.getExpectedBudget()),
                value(registration.getNote()),
                registration.getCreatedAt() == null ? "-" : registration.getCreatedAt().format(TIME_FORMATTER)
        );
    }

    private String value(String value) {
        return StringUtils.hasText(value) ? value : "-";
    }

    private String budget(BigDecimal value) {
        return value == null ? "-" : value.stripTrailingZeros().toPlainString();
    }
}
