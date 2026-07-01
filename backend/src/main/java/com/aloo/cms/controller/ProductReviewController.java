package com.aloo.cms.controller;

import com.aloo.cms.dto.ProductReviewResponse;
import com.aloo.cms.dto.ProductReviewSubmitRequest;
import com.aloo.cms.service.ProductReviewService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/products/{productId}/reviews")
@RequiredArgsConstructor
public class ProductReviewController {

    private final ProductReviewService productReviewService;

    @GetMapping
    public List<ProductReviewResponse> findApproved(@PathVariable Long productId) {
        return productReviewService.findApprovedByProduct(productId);
    }

    @GetMapping("/mine")
    public ResponseEntity<ProductReviewResponse> findMine(
            @PathVariable Long productId,
            Authentication authentication
    ) {
        ProductReviewResponse review = productReviewService.findMine(productId, authentication);
        return review == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(review);
    }

    @PostMapping
    public ResponseEntity<ProductReviewResponse> submit(
            @PathVariable Long productId,
            @Valid @RequestBody ProductReviewSubmitRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(productReviewService.submit(productId, request, authentication));
    }
}
