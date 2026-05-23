package com.aloo.cms.config;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.CustomerUser;
import com.aloo.cms.entity.FranchiseContent;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.repository.CustomerUserRepository;
import com.aloo.cms.repository.FranchiseContentRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final AdminUserRepository adminUserRepository;
    private final CustomerUserRepository customerUserRepository;
    private final FranchiseContentRepository franchiseContentRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.email}")
    private String adminEmail;

    @Value("${app.admin.password}")
    private String adminPassword;

    @Value("${app.admin.full-name}")
    private String adminFullName;

    @Value("${app.user.email:user@aloo.vn}")
    private String userEmail;

    @Value("${app.user.password:change-me}")
    private String userPassword;

    @Value("${app.user.full-name:ALOO User}")
    private String userFullName;

    @Override
    public void run(String... args) {
        seedAdmin();
        seedCustomerUser();
        seedFranchiseContents();
    }

    private void seedAdmin() {
        if (adminUserRepository.existsByEmailIgnoreCase(adminEmail.trim().toLowerCase())) {
            return;
        }

        AdminUser admin = new AdminUser();
        admin.setEmail(adminEmail.trim().toLowerCase());
        admin.setFullName(adminFullName);
        admin.setPhone("0900 888 168");
        admin.setPasswordHash(passwordEncoder.encode(adminPassword));
        admin.setRole(UserRole.ADMIN);
        admin.setStatus("ACTIVE");

        adminUserRepository.save(admin);
        log.info("Seeded default admin user: {}", admin.getEmail());
    }

    private void seedCustomerUser() {
        if (customerUserRepository.existsByEmailIgnoreCase(userEmail.trim().toLowerCase())) {
            return;
        }

        CustomerUser user = new CustomerUser();
        user.setEmail(userEmail.trim().toLowerCase());
        user.setFullName(userFullName);
        user.setPhone("0901 234 567");
        user.setPasswordHash(passwordEncoder.encode(userPassword));
        user.setRole("USER");
        user.setStatus("ACTIVE");

        customerUserRepository.save(user);
        log.info("Seeded default customer user: {}", user.getEmail());
    }

    private void seedFranchiseContents() {
        if (franchiseContentRepository.count() > 0) {
            return;
        }

        franchiseContentRepository.saveAll(List.of(
                content("benefits", "Công thức đồng bộ", "Định lượng, topping và quy trình pha chế để đào tạo nhanh.", 1),
                content("benefits", "Nhận diện sẵn sàng", "Bộ màu, menu, bảng hiệu và vật phẩm bán hàng thống nhất.", 2),
                content("benefits", "Hỗ trợ khai trương", "Checklist vận hành, truyền thông tại điểm bán và theo dõi sau mở bán.", 3),
                content("conditions", "Mặt bằng", "Diện tích từ 12m2, mặt tiền dễ nhận diện và có khu vực bảo quản nguyên liệu.", 1),
                content("conditions", "Vốn đầu tư", "Nguồn vốn phù hợp với gói kiosk, cửa hàng tiêu chuẩn hoặc flagship mini.", 2),
                content("conditions", "Vận hành", "Cam kết tuân thủ quy trình sản phẩm, vệ sinh và dịch vụ của thương hiệu.", 3),
                content("process", "Tiếp nhận thông tin", "Đội ngũ ALOO liên hệ và xác nhận nhu cầu đầu tư.", 1),
                content("process", "Khảo sát khu vực", "Đánh giá lưu lượng khách, đối thủ và mức chi phí mặt bằng.", 2),
                content("process", "Triển khai cửa hàng", "Thiết kế, lắp đặt, đào tạo và chuẩn bị khai trương.", 3),
                cost("Gói xe đẩy / kiosk", "120 - 180 triệu", "Phù hợp điểm bán nhỏ, chi phí gọn.", 1),
                cost("Gói cửa hàng tiêu chuẩn", "280 - 450 triệu", "Dành cho mặt bằng phố hoặc trung tâm khu dân cư.", 2),
                cost("Gói flagship mini", "500 - 750 triệu", "Không gian trải nghiệm đầy đủ và nhận diện nổi bật.", 3)
        ));
        log.info("Seeded default franchise content sections");
    }

    private FranchiseContent content(String sectionKey, String title, String content, int sortOrder) {
        FranchiseContent item = new FranchiseContent();
        item.setSectionKey(sectionKey);
        item.setTitle(title);
        item.setContent(content);
        item.setSortOrder(sortOrder);
        item.setStatus("ACTIVE");
        return item;
    }

    private FranchiseContent cost(String title, String amount, String note, int sortOrder) {
        FranchiseContent item = content("costs", title, null, sortOrder);
        item.setAmount(amount);
        item.setNote(note);
        return item;
    }
}
