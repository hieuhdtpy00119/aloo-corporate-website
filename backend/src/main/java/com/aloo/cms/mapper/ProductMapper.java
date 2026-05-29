package com.aloo.cms.mapper;

import com.aloo.cms.dto.ProductRequest;
import com.aloo.cms.dto.ProductResponse;
import com.aloo.cms.entity.Product;
import org.springframework.stereotype.Component;

@Component
public class ProductMapper {

    public Product toEntity(ProductRequest request) {
        Product product = new Product();
        updateEntity(product, request);
        return product;
    }

    public void updateEntity(Product product, ProductRequest request) {
        product.setName(MapperUtils.required(request.name()));
        product.setSlug(MapperUtils.slug(request.slug()));
        product.setDescription(MapperUtils.nullable(request.description()));
        product.setShortDescription(MapperUtils.nullable(request.shortDescription()));
        product.setDetailContent(MapperUtils.nullable(request.detailContent()));
        product.setIngredients(MapperUtils.nullable(request.ingredients()));
        product.setTasteProfile(MapperUtils.nullable(request.tasteProfile()));
        product.setServingSuggestion(MapperUtils.nullable(request.servingSuggestion()));
        product.setGallery(MapperUtils.nullable(request.gallery()));
        product.setFaqs(MapperUtils.nullable(request.faqs()));
        product.setPrice(request.price());
        product.setImageUrl(MapperUtils.nullable(request.imageUrl()));
        product.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        product.setFeatured(Boolean.TRUE.equals(request.featured()));
        product.setSeoTitle(MapperUtils.nullable(request.seoTitle()));
        product.setSeoDescription(MapperUtils.nullable(request.seoDescription()));
        product.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public ProductResponse toResponse(Product product) {
        Long categoryId = product.getCategory() == null ? null : product.getCategory().getId();
        String categoryName = product.getCategory() == null ? null : product.getCategory().getName();
        return new ProductResponse(
                product.getId(),
                product.getName(),
                product.getSlug(),
                product.getDescription(),
                product.getShortDescription(),
                product.getDetailContent(),
                product.getIngredients(),
                product.getTasteProfile(),
                product.getServingSuggestion(),
                product.getGallery(),
                product.getFaqs(),
                product.getPrice(),
                product.getImageUrl(),
                categoryId,
                categoryName,
                product.getSortOrder(),
                product.getFeatured(),
                product.getSeoTitle(),
                product.getSeoDescription(),
                product.getStatus(),
                product.getCreatedAt(),
                product.getUpdatedAt()
        );
    }
}

