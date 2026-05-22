package com.aloo.cms.mapper;

import com.aloo.cms.dto.CategoryRequest;
import com.aloo.cms.dto.CategoryResponse;
import com.aloo.cms.entity.Category;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {

    public Category toEntity(CategoryRequest request) {
        Category category = new Category();
        updateEntity(category, request);
        return category;
    }

    public void updateEntity(Category category, CategoryRequest request) {
        category.setName(MapperUtils.required(request.name()));
        category.setSlug(MapperUtils.slug(request.slug()));
        String existingType = category.getType() == null ? "ARTICLE" : category.getType();
        category.setType(MapperUtils.status(request.type(), existingType));
        category.setDescription(MapperUtils.nullable(request.description()));
        category.setParentId(request.parentId());
        category.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        category.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
        String existingLanguage = category.getLanguageCode() == null ? "vi" : category.getLanguageCode();
        category.setLanguageCode(MapperUtils.status(request.languageCode(), existingLanguage).toLowerCase());
    }

    public CategoryResponse toResponse(Category category) {
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getSlug(),
                category.getType(),
                category.getDescription(),
                category.getParentId(),
                category.getSortOrder(),
                category.getStatus(),
                category.getLanguageCode()
        );
    }
}
