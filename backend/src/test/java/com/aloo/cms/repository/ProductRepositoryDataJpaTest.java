package com.aloo.cms.repository;

import static org.assertj.core.api.Assertions.assertThat;

import com.aloo.cms.entity.Product;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

@DataJpaTest
@ActiveProfiles("test")
class ProductRepositoryDataJpaTest {

    @Autowired
    private ProductRepository productRepository;

    @Test
    void saveFindAndSlugLookupWorkThroughJpa() {
        Product product = new Product();
        product.setName("Kem bo JPA");
        product.setSlug("kem-bo-jpa");
        product.setDescription("Repository integration test");
        product.setPrice(BigDecimal.ZERO);
        product.setSortOrder(1);
        product.setStatus("ACTIVE");

        Product saved = productRepository.saveAndFlush(product);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(productRepository.existsBySlug("kem-bo-jpa")).isTrue();
        assertThat(productRepository.findBySlug("kem-bo-jpa"))
                .isPresent()
                .get()
                .extracting(Product::getName)
                .isEqualTo("Kem bo JPA");
    }
}
