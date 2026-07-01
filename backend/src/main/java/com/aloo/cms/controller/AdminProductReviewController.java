package com.aloo.cms.controller;

import com.aloo.cms.dto.ProductReviewResponse;
import com.aloo.cms.dto.ProductReviewStatusUpdateRequest;
import com.aloo.cms.service.ProductReviewService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/product-reviews")
@RequiredArgsConstructor
public class AdminProductReviewController {

    private final ProductReviewService productReviewService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public List<ProductReviewResponse> findAll() {
        return productReviewService.findAllForAdmin();
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ProductReviewResponse updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody ProductReviewStatusUpdateRequest request
    ) {
        return productReviewService.updateStatus(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        productReviewService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
