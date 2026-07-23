package com.aloo.cms.service;

import com.aloo.cms.dto.ProductReviewResponse;
import com.aloo.cms.dto.ProductReviewStatusUpdateRequest;
import com.aloo.cms.dto.ProductReviewSubmitRequest;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.Product;
import com.aloo.cms.entity.ProductReview;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.ProductReviewMapper;
import com.aloo.cms.repository.ProductRepository;
import com.aloo.cms.repository.ProductReviewRepository;
import com.aloo.cms.security.CustomUserDetails;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProductReviewService {

    private final ProductReviewRepository productReviewRepository;
    private final ProductRepository productRepository;
    private final ProductReviewMapper productReviewMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<ProductReviewResponse> findApprovedByProduct(Long productId) {
        getProduct(productId);
        List<ProductReview> reviews = productReviewRepository
                .findByProductIdAndStatusOrderByCreatedAtDesc(productId, ProductReview.STATUS_APPROVED);
        Product product = getProduct(productId);
        return reviews.stream()
                .map(review -> productReviewMapper.toResponse(review, product))
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductReviewResponse findMine(Long productId, Authentication authentication) {
        AdminUser user = currentUser(authentication);
        getProduct(productId);
        return productReviewRepository.findByProductIdAndUserId(productId, user.getId())
                .map(review -> productReviewMapper.toResponse(review, getProduct(productId)))
                .orElse(null);
    }

    @Transactional
    public ProductReviewResponse submit(Long productId, ProductReviewSubmitRequest request, Authentication authentication) {
        AdminUser user = currentUser(authentication);
        Product product = getProduct(productId);

        return productReviewRepository.findByProductIdAndUserId(productId, user.getId())
                .map(existing -> updateExistingReview(existing, request, user, product))
                .orElseGet(() -> createReview(productId, request, user, product));
    }

    @Transactional(readOnly = true)
    public List<ProductReviewResponse> findAllForAdmin() {
        List<ProductReview> reviews = productReviewRepository.findAllByOrderByCreatedAtDesc();
        Map<Long, Product> productsById = productRepository.findAllById(
                reviews.stream().map(ProductReview::getProductId).distinct().toList()
        ).stream().collect(Collectors.toMap(Product::getId, Function.identity()));

        return reviews.stream()
                .map(review -> productReviewMapper.toResponse(
                        review,
                        productsById.get(review.getProductId())
                ))
                .toList();
    }

    @Transactional
    public ProductReviewResponse updateStatus(Long id, ProductReviewStatusUpdateRequest request) {
        ProductReview review = getReview(id);
        String nextStatus = normalizeModerationStatus(request.status());
        String currentStatus = review.getStatus();

        if (nextStatus.equals(currentStatus)) {
            Product product = getProduct(review.getProductId());
            return productReviewMapper.toResponse(review, product);
        }

        review.setStatus(nextStatus);
        Product product = getProduct(review.getProductId());
        ProductReviewResponse response = productReviewMapper.toResponse(productReviewRepository.save(review), product);
        auditLogService.logStatusChanged(
                "PRODUCT_REVIEW",
                String.valueOf(response.id()),
                reviewLabel(response),
                response.status()
        );
        return response;
    }

    @Transactional
    public void delete(Long id) {
        ProductReview review = getReview(id);
        Product product = getProduct(review.getProductId());
        ProductReviewResponse response = productReviewMapper.toResponse(review, product);
        auditLogService.logDeleted("PRODUCT_REVIEW", String.valueOf(review.getId()), reviewLabel(response), String.valueOf(review.getId()));
        productReviewRepository.delete(review);
    }

    private String reviewLabel(ProductReviewResponse response) {
        String productName = response.productName() == null ? "product" : response.productName();
        return response.customerName() + " - " + productName;
    }

    private ProductReviewResponse createReview(
            Long productId,
            ProductReviewSubmitRequest request,
            AdminUser user,
            Product product
    ) {
        ProductReview review = new ProductReview();
        review.setProductId(productId);
        review.setUserId(user.getId());
        review.setCustomerName(user.getFullName());
        review.setAvatarUrl(user.getAvatarUrl());
        review.setRating(request.rating());
        review.setContent(request.content().trim());
        review.setStatus(ProductReview.STATUS_PENDING);
        return productReviewMapper.toResponse(productReviewRepository.save(review), product);
    }

    private ProductReviewResponse updateExistingReview(
            ProductReview existing,
            ProductReviewSubmitRequest request,
            AdminUser user,
            Product product
    ) {
        if (ProductReview.STATUS_APPROVED.equals(existing.getStatus())
                || ProductReview.STATUS_PENDING.equals(existing.getStatus())) {
            throw new BadRequestException("You have already reviewed this product");
        }

        existing.setCustomerName(user.getFullName());
        existing.setAvatarUrl(user.getAvatarUrl());
        existing.setRating(request.rating());
        existing.setContent(request.content().trim());
        existing.setStatus(ProductReview.STATUS_PENDING);
        return productReviewMapper.toResponse(productReviewRepository.save(existing), product);
    }

    private Product getProduct(Long productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
    }

    private ProductReview getReview(Long id) {
        return productReviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product review not found"));
    }

    private AdminUser currentUser(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof CustomUserDetails principal)) {
            throw new ResourceNotFoundException("Authenticated user not found");
        }
        return principal.getUser();
    }

    private String normalizeModerationStatus(String status) {
        if (status == null || status.isBlank()) {
            throw new BadRequestException("Status is required");
        }
        String normalized = status.trim().toUpperCase();
        if (!ProductReview.STATUS_APPROVED.equals(normalized) && !ProductReview.STATUS_REJECTED.equals(normalized)) {
            throw new BadRequestException("Status must be APPROVED or REJECTED");
        }
        return normalized;
    }
}
