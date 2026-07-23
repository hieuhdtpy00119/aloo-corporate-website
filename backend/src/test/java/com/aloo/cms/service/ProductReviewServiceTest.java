package com.aloo.cms.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.aloo.cms.dto.ProductReviewResponse;
import com.aloo.cms.dto.ProductReviewSubmitRequest;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.Product;
import com.aloo.cms.entity.ProductReview;
import com.aloo.cms.mapper.ProductReviewMapper;
import com.aloo.cms.repository.ProductRepository;
import com.aloo.cms.repository.ProductReviewRepository;
import com.aloo.cms.security.CustomUserDetails;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

@ExtendWith(MockitoExtension.class)
class ProductReviewServiceTest {

    @Mock
    private ProductReviewRepository productReviewRepository;

    @Mock
    private ProductRepository productRepository;

    @Mock
    private AuditLogService auditLogService;

    @Test
    void newReviewWaitsForAdminApproval() {
        Product product = product();
        AdminUser user = user();
        when(productRepository.findById(product.getId())).thenReturn(Optional.of(product));
        when(productReviewRepository.findByProductIdAndUserId(product.getId(), user.getId()))
                .thenReturn(Optional.empty());
        when(productReviewRepository.save(any(ProductReview.class))).thenAnswer(invocation -> {
            ProductReview review = invocation.getArgument(0);
            review.setId(100L);
            return review;
        });

        ProductReviewResponse response = service().submit(
                product.getId(),
                new ProductReviewSubmitRequest(5, "Sản phẩm rất ngon và đáng thử"),
                authentication(user)
        );

        assertThat(response.status()).isEqualTo(ProductReview.STATUS_PENDING);
    }

    @Test
    void resubmittedRejectedReviewReturnsToPending() {
        Product product = product();
        AdminUser user = user();
        ProductReview rejected = new ProductReview();
        rejected.setId(100L);
        rejected.setProductId(product.getId());
        rejected.setUserId(user.getId());
        rejected.setCustomerName(user.getFullName());
        rejected.setRating(2);
        rejected.setContent("Nội dung cũ đã bị từ chối");
        rejected.setStatus(ProductReview.STATUS_REJECTED);

        when(productRepository.findById(product.getId())).thenReturn(Optional.of(product));
        when(productReviewRepository.findByProductIdAndUserId(product.getId(), user.getId()))
                .thenReturn(Optional.of(rejected));
        when(productReviewRepository.save(rejected)).thenReturn(rejected);

        ProductReviewResponse response = service().submit(
                product.getId(),
                new ProductReviewSubmitRequest(4, "Nội dung đã được khách hàng chỉnh sửa"),
                authentication(user)
        );

        assertThat(response.status()).isEqualTo(ProductReview.STATUS_PENDING);
        assertThat(response.content()).isEqualTo("Nội dung đã được khách hàng chỉnh sửa");
    }

    private ProductReviewService service() {
        return new ProductReviewService(
                productReviewRepository,
                productRepository,
                new ProductReviewMapper(),
                auditLogService
        );
    }

    private Product product() {
        Product product = new Product();
        product.setId(10L);
        product.setName("Kem bơ ALOO");
        return product;
    }

    private AdminUser user() {
        AdminUser user = new AdminUser();
        user.setId(20L);
        user.setEmail("customer@example.com");
        user.setFullName("Khách hàng ALOO");
        user.setPasswordHash("not-used");
        user.setStatus("ACTIVE");
        return user;
    }

    private Authentication authentication(AdminUser user) {
        return new UsernamePasswordAuthenticationToken(new CustomUserDetails(user), null);
    }
}
