# Telegram notification for ALOO Franchise CMS

Frontend must only call:

```http
POST /api/franchise-registrations
```

Telegram bot token and chat id must stay in the Spring Boot backend. Do not expose them through Vue env files.

## application-example.properties

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=ALOO_Franchise_CMS;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=

telegram.bot.token=${TELEGRAM_BOT_TOKEN:}
telegram.chat.id=${TELEGRAM_CHAT_ID:}
app.cms.url=${APP_CMS_URL:http://localhost:5173/admin/registrations}
```

## TelegramBotService.java

```java
package vn.aloo.cms.service;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import vn.aloo.cms.entity.FranchiseRegistration;

@Service
public class TelegramBotService {
    private static final Logger log = LoggerFactory.getLogger(TelegramBotService.class);

    private final RestClient restClient;

    @Value("${telegram.bot.token:}")
    private String botToken;

    @Value("${telegram.chat.id:}")
    private String chatId;

    @Value("${app.cms.url:http://localhost:5173/admin/registrations}")
    private String cmsUrl;

    public TelegramBotService(RestClient.Builder restClientBuilder) {
        this.restClient = restClientBuilder.build();
    }

    public void notifyNewRegistration(FranchiseRegistration registration) {
        if (botToken == null || botToken.isBlank() || chatId == null || chatId.isBlank()) {
            log.warn("Telegram config is missing. Skip notification.");
            return;
        }

        try {
            String url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
            restClient.post()
                .uri(url)
                .contentType(MediaType.APPLICATION_JSON)
                .body(new TelegramMessage(chatId, buildMessage(registration)))
                .retrieve()
                .toBodilessEntity();
        } catch (Exception ex) {
            log.error("Failed to send Telegram notification for registration id={}", registration.getId(), ex);
        }
    }

    private String buildMessage(FranchiseRegistration registration) {
        return """
            🚀 ALOO có đăng ký tư vấn mới!

            👤 Họ tên: %s
            📞 Số điện thoại: %s
            📧 Email: %s
            📍 Khu vực: %s
            💰 Số vốn: %s
            📝 Ghi chú: %s
            🕒 Thời gian: %s

            Vào CMS để xử lý lead:
            %s
            """.formatted(
                safe(registration.getFullName()),
                safe(registration.getPhone()),
                safe(registration.getEmail()),
                safe(registration.getProvince()),
                formatMoney(registration.getExpectedBudget()),
                safe(registration.getNote()),
                formatDateTime(registration.getCreatedAt()),
                cmsUrl
            );
    }

    private String safe(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }

    private String formatMoney(BigDecimal value) {
        if (value == null) return "-";
        NumberFormat format = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
        return format.format(value) + " VNĐ";
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) return "-";
        return value.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    private record TelegramMessage(String chat_id, String text) {}
}
```

## FranchiseRegistrationService.java

Call Telegram after the database save succeeds. Telegram failure is already swallowed inside `TelegramBotService`, so the API response still succeeds.

```java
@Service
public class FranchiseRegistrationService {
    private final FranchiseRegistrationRepository repository;
    private final TelegramBotService telegramBotService;

    public FranchiseRegistrationService(
        FranchiseRegistrationRepository repository,
        TelegramBotService telegramBotService
    ) {
        this.repository = repository;
        this.telegramBotService = telegramBotService;
    }

    @Transactional
    public FranchiseRegistration create(CreateFranchiseRegistrationRequest request) {
        FranchiseRegistration registration = new FranchiseRegistration();
        registration.setFullName(request.fullName());
        registration.setPhone(request.phone());
        registration.setEmail(request.email());
        registration.setProvince(request.province());
        registration.setExpectedBudget(request.expectedBudget());
        registration.setNote(request.note());
        registration.setStatus("NEW");
        registration.setCreatedAt(LocalDateTime.now());
        registration.setUpdatedAt(LocalDateTime.now());

        FranchiseRegistration saved = repository.save(registration);
        telegramBotService.notifyNewRegistration(saved);
        return saved;
    }
}
```

## Controller endpoint

```java
@RestController
@RequestMapping("/api/franchise-registrations")
public class FranchiseRegistrationController {
    private final FranchiseRegistrationService service;

    public FranchiseRegistrationController(FranchiseRegistrationService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<FranchiseRegistration> create(@RequestBody @Valid CreateFranchiseRegistrationRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }
}
```

## Request DTO

```java
public record CreateFranchiseRegistrationRequest(
    @NotBlank String fullName,
    @NotBlank String phone,
    @Email String email,
    @NotBlank String province,
    BigDecimal expectedBudget,
    String note
) {}
```

## Security notes

- Keep `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in backend environment variables.
- Never commit real token values to GitHub.
- Frontend `.env` must only contain `VITE_API_URL`.
- If Telegram is down or token is invalid, log the error and still return success after the lead is saved.
