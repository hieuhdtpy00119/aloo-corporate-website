package com.aloo.cms.service;

import com.aloo.cms.dto.PostRequest;
import com.aloo.cms.dto.PostResponse;
import com.aloo.cms.entity.Category;
import com.aloo.cms.entity.Post;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.PostMapper;
import com.aloo.cms.repository.CategoryRepository;
import com.aloo.cms.repository.PostRepository;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PostService {

    public static final String STATUS_PUBLISHED = "PUBLISHED";

    private final PostRepository postRepository;
    private final CategoryRepository categoryRepository;
    private final PostMapper postMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<PostResponse> findAll() {
        return postRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(postMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PostResponse> findPublished() {
        return postRepository.findByStatusIgnoreCase(STATUS_PUBLISHED, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(postMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public PostResponse findById(Long id) {
        return postMapper.toResponse(getPost(id));
    }

    @Transactional(readOnly = true)
    public PostResponse findPublishedById(Long id) {
        Post post = getPost(id);
        ensurePublished(post);
        return postMapper.toResponse(post);
    }

    @Transactional(readOnly = true)
    public PostResponse findBySlug(String slug) {
        return postMapper.toResponse(postRepository.findBySlug(slug.trim().toLowerCase())
                .orElseThrow(() -> new ResourceNotFoundException("Post not found")));
    }

    @Transactional(readOnly = true)
    public PostResponse findPublishedBySlug(String slug) {
        Post post = postRepository.findBySlugAndStatusIgnoreCase(slug.trim().toLowerCase(Locale.ROOT), STATUS_PUBLISHED)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        return postMapper.toResponse(post);
    }

    private void ensurePublished(Post post) {
        if (post.getStatus() == null || !STATUS_PUBLISHED.equalsIgnoreCase(post.getStatus())) {
            throw new ResourceNotFoundException("Post not found");
        }
    }

    @Transactional
    public PostResponse create(PostRequest request) {
        ensureSlugAvailable(request.slug(), null);
        Post post = postMapper.toEntity(request);
        post.setCategory(resolveCategory(request));
        PostResponse response = postMapper.toResponse(postRepository.save(post));
        auditLogService.logCreated("POST", String.valueOf(response.id()), response.title(), response.slug());
        return response;
    }

    @Transactional
    public PostResponse update(Long id, PostRequest request) {
        Post post = getPost(id);
        ensureSlugAvailable(request.slug(), id);
        postMapper.updateEntity(post, request);
        post.setCategory(resolveCategory(request));
        PostResponse response = postMapper.toResponse(postRepository.save(post));
        auditLogService.logUpdated("POST", String.valueOf(response.id()), response.title(), response.slug());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        Post post = getPost(id);
        auditLogService.logDeleted("POST", String.valueOf(post.getId()), post.getTitle(), post.getSlug());
        postRepository.findAll().forEach(item -> {
            if (item.getRelatedPostIds().remove(id)) {
                postRepository.save(item);
            }
        });
        postRepository.delete(post);
    }

    private Post getPost(Long id) {
        return postRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
    }

    private void ensureSlugAvailable(String slug, Long currentId) {
        String normalizedSlug = slug.trim().toLowerCase();
        boolean exists = currentId == null
                ? postRepository.existsBySlug(normalizedSlug)
                : postRepository.existsBySlugAndIdNot(normalizedSlug, currentId);

        if (exists) {
            throw new BadRequestException("Post slug is already used");
        }
    }

    private Category resolveCategory(PostRequest request) {
        if (request.categoryId() != null) {
            return categoryRepository.findById(request.categoryId())
                    .orElseThrow(() -> new BadRequestException("Post category does not exist"));
        }

        if (request.category() == null || request.category().isBlank()) {
            return null;
        }

        return categoryRepository.findFirstByTypeAndNameIgnoreCase("ARTICLE", request.category().trim())
                .or(() -> categoryRepository.findFirstByNameIgnoreCase(request.category().trim()))
                .orElse(null);
    }
}
