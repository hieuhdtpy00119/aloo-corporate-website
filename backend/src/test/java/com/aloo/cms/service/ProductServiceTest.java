package com.aloo.cms.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.aloo.cms.dto.ProductRequest;
import com.aloo.cms.dto.ProductResponse;
import com.aloo.cms.entity.Category;
import com.aloo.cms.entity.Product;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.mapper.ProductMapper;
import com.aloo.cms.repository.CategoryRepository;
import com.aloo.cms.repository.ProductRepository;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private AuditLogService auditLogService;

    @Test
    void createNormalizesSlugAndSavesProduct() {
        ProductService service = new ProductService(productRepository, categoryRepository, new ProductMapper(), auditLogService);
        Category category = new Category();
        category.setId(10L);
        category.setName("Kem bo");

        when(productRepository.existsBySlug("kem-bo-test")).thenReturn(false);
        when(categoryRepository.findFirstByTypeAndNameIgnoreCase("PRODUCT", "Kem bo"))
                .thenReturn(Optional.of(category));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> {
            Product product = invocation.getArgument(0);
            product.setId(99L);
            return product;
        });

        ProductResponse response = service.create(new ProductRequest(
                "Kem bo test",
                "kem-bo-test",
                "Mo ta",
                "Mo ta hero",
                "Noi dung chi tiet",
                "Bo sap\nKem tuoi",
                "Beo min\nMat lanh",
                "Dung lanh",
                "/uploads/gallery.jpg",
                "Hoi? | Dap",
                BigDecimal.ZERO,
                "/uploads/product.jpg",
                null,
                "Kem bo",
                1,
                true,
                "SEO title",
                "SEO description",
                "ACTIVE"
        ));

        assertThat(response.id()).isEqualTo(99L);
        assertThat(response.slug()).isEqualTo("kem-bo-test");
        assertThat(response.category()).isEqualTo("Kem bo");
        verify(productRepository).existsBySlug("kem-bo-test");
        verify(productRepository).save(any(Product.class));
    }

    @Test
    void createRejectsDuplicateSlug() {
        ProductService service = new ProductService(productRepository, categoryRepository, new ProductMapper(), auditLogService);
        when(productRepository.existsBySlug("used-slug")).thenReturn(true);

        ProductRequest request = new ProductRequest(
                "Kem bo",
                "used-slug",
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                BigDecimal.ZERO,
                null,
                null,
                null,
                0,
                false,
                null,
                null,
                "ACTIVE"
        );

        assertThatThrownBy(() -> service.create(request))
                .isInstanceOf(BadRequestException.class)
                .hasMessage("Product slug is already used");
    }
}

