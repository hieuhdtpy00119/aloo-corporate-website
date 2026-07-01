package com.aloo.cms.service;

import com.aloo.cms.dto.ProductRequest;
import com.aloo.cms.dto.ProductResponse;
import com.aloo.cms.entity.Category;
import com.aloo.cms.entity.Product;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.ProductMapper;
import com.aloo.cms.repository.CategoryRepository;
import com.aloo.cms.repository.ProductRepository;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductMapper productMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<ProductResponse> findAll() {
        return productRepository.findAll(Sort.by("sortOrder").ascending()
                        .and(Sort.by("createdAt").descending()))
                .stream()
                .map(productMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductResponse findById(Long id) {
        return productMapper.toResponse(getProduct(id));
    }

    @Transactional(readOnly = true)
    public ProductResponse findBySlug(String slug) {
        return productMapper.toResponse(productRepository.findBySlugAndStatus(slug.trim().toLowerCase(Locale.ROOT), "ACTIVE")
                .orElseThrow(() -> new ResourceNotFoundException("Product not found")));
    }

    @Transactional
    public ProductResponse create(ProductRequest request) {
        ensureSlugAvailable(request.slug(), null);
        Product product = productMapper.toEntity(request);
        product.setCategory(resolveCategory(request));
        ProductResponse response = productMapper.toResponse(productRepository.save(product));
        auditLogService.logCreated("PRODUCT", String.valueOf(response.id()), response.name(), response.slug());
        return response;
    }

    @Transactional
    public ProductResponse update(Long id, ProductRequest request) {
        Product product = getProduct(id);
        ensureSlugAvailable(request.slug(), id);
        productMapper.updateEntity(product, request);
        product.setCategory(resolveCategory(request));
        ProductResponse response = productMapper.toResponse(productRepository.save(product));
        auditLogService.logUpdated("PRODUCT", String.valueOf(response.id()), response.name(), response.slug());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        Product product = getProduct(id);
        auditLogService.logDeleted("PRODUCT", String.valueOf(product.getId()), product.getName(), product.getSlug());
        productRepository.delete(product);
    }

    private Product getProduct(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
    }

    private void ensureSlugAvailable(String slug, Long currentId) {
        String normalizedSlug = slug.trim().toLowerCase();
        boolean exists = currentId == null
                ? productRepository.existsBySlug(normalizedSlug)
                : productRepository.existsBySlugAndIdNot(normalizedSlug, currentId);

        if (exists) {
            throw new BadRequestException("Product slug is already used");
        }
    }

    private Category resolveCategory(ProductRequest request) {
        if (request.categoryId() != null) {
            return categoryRepository.findById(request.categoryId())
                    .orElseThrow(() -> new BadRequestException("Product category does not exist"));
        }

        if (request.category() == null || request.category().isBlank()) {
            return null;
        }

        String categoryName = request.category().trim();
        return categoryRepository.findFirstByTypeAndNameIgnoreCase("PRODUCT", categoryName)
                .orElseGet(() -> createProductCategory(categoryName));
    }

    private Category createProductCategory(String name) {
        Category category = new Category();
        category.setName(name);
        category.setSlug(slugify(name));
        category.setType("PRODUCT");
        category.setStatus("ACTIVE");
        category.setLanguageCode("vi");
        return categoryRepository.save(category);
    }

    private String slugify(String value) {
        String normalized = java.text.Normalizer.normalize(value, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return normalized.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-|-$)", "");
    }
}

