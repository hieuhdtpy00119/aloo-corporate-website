package com.aloo.cms.mapper;

import com.aloo.cms.dto.ProductReviewResponse;
import com.aloo.cms.entity.Product;
import com.aloo.cms.entity.ProductReview;
import org.springframework.stereotype.Component;

@Component
public class ProductReviewMapper {

    public ProductReviewResponse toResponse(ProductReview review, Product product) {
        return new ProductReviewResponse(
                review.getId(),
                review.getProductId(),
                product != null ? product.getName() : null,
                review.getUserId(),
                review.getCustomerName(),
                review.getAvatarUrl(),
                review.getRating(),
                review.getContent(),
                review.getStatus(),
                review.getCreatedAt(),
                review.getUpdatedAt()
        );
    }
}
