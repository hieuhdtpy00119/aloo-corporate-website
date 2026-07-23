package com.aloo.cms.repository;

import com.aloo.cms.entity.Product;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {

    Optional<Product> findBySlug(String slug);

    Optional<Product> findBySlugAndStatus(String slug, String status);

    List<Product> findByStatusIgnoreCase(String status, Sort sort);

    boolean existsBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Long id);
}
