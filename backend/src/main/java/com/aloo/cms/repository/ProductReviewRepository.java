package com.aloo.cms.repository;

import com.aloo.cms.entity.ProductReview;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {

    List<ProductReview> findByProductIdAndStatusOrderByCreatedAtDesc(Long productId, String status);

    Optional<ProductReview> findByProductIdAndUserId(Long productId, Long userId);

    List<ProductReview> findAllByOrderByCreatedAtDesc();
}
