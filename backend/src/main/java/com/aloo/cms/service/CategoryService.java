package com.aloo.cms.service;

import com.aloo.cms.dto.CategoryRequest;
import com.aloo.cms.dto.CategoryResponse;
import com.aloo.cms.entity.Category;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.CategoryMapper;
import com.aloo.cms.repository.CategoryRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;

    @Transactional(readOnly = true)
    public List<CategoryResponse> findAll() {
        return categoryRepository.findAll(Sort.by("type").ascending()
                        .and(Sort.by("sortOrder").ascending())
                        .and(Sort.by("name").ascending()))
                .stream()
                .map(categoryMapper::toResponse)
                .toList();
    }

    @Transactional
    public CategoryResponse create(CategoryRequest request) {
        ensureSlugAvailable(request.slug(), request.type(), null);
        Category category = categoryMapper.toEntity(request);
        return categoryMapper.toResponse(categoryRepository.save(category));
    }

    @Transactional
    public CategoryResponse update(Long id, CategoryRequest request) {
        Category category = getCategory(id);
        ensureSlugAvailable(request.slug(), request.type(), id);
        categoryMapper.updateEntity(category, request);
        return categoryMapper.toResponse(categoryRepository.save(category));
    }

    @Transactional
    public void delete(Long id) {
        Category category = getCategory(id);
        categoryRepository.delete(category);
    }

    private Category getCategory(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
    }

    private void ensureSlugAvailable(String slug, String requestedType, Long currentId) {
        String normalizedSlug = slug.trim().toLowerCase();
        String type = requestedType == null || requestedType.isBlank()
                ? requestTypeFallback(currentId, "ARTICLE")
                : requestedType.trim().toUpperCase();
        boolean exists = currentId == null
                ? categoryRepository.existsByTypeAndSlug(type, normalizedSlug)
                : categoryRepository.existsByTypeAndSlugAndIdNot(type, normalizedSlug, currentId);

        if (exists) {
            throw new BadRequestException("Category slug is already used");
        }
    }

    private String requestTypeFallback(Long currentId, String fallback) {
        if (currentId == null) {
            return fallback;
        }
        return categoryRepository.findById(currentId)
                .map(Category::getType)
                .orElse(fallback);
    }
}
