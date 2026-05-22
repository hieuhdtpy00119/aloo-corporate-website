package com.aloo.cms.mapper;

import com.aloo.cms.dto.PostRequest;
import com.aloo.cms.dto.PostResponse;
import com.aloo.cms.entity.Post;
import com.aloo.cms.entity.PostImage;
import com.aloo.cms.security.HtmlSanitizer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PostMapper {

    public Post toEntity(PostRequest request) {
        Post post = new Post();
        updateEntity(post, request);
        return post;
    }

    public void updateEntity(Post post, PostRequest request) {
        post.setTitle(MapperUtils.required(request.title()));
        post.setSlug(MapperUtils.slug(request.slug()));
        post.setExcerpt(MapperUtils.nullable(request.excerpt()));
        post.setContent(MapperUtils.nullable(HtmlSanitizer.sanitize(request.content())));
        post.setThumbnailUrl(MapperUtils.nullable(request.thumbnailUrl()));
        post.setAuthor(MapperUtils.nullable(request.author()));
        post.setSource(MapperUtils.nullable(request.source()));
        post.setSourceLink(MapperUtils.nullable(request.sourceLink()));
        post.setArticleType(MapperUtils.nullable(request.articleType()));
        post.setStatus(MapperUtils.status(request.status(), "DRAFT"));
        post.setPublishedAt(request.publishedAt());
        post.setSeoTitle(MapperUtils.nullable(request.seoTitle()));
        post.setSeoDescription(MapperUtils.nullable(firstNonBlank(request.seoDescription(), request.metaDescription())));
        post.setMetaKeywords(MapperUtils.nullable(request.metaKeywords()));
        post.setCanonicalUrl(MapperUtils.nullable(request.canonicalUrl()));
        post.setTags(joinTags(request.tags()));
        replaceGallery(post, request.gallery());
        replaceRelatedPosts(post, request.relatedPostIds());
    }

    public PostResponse toResponse(Post post) {
        Long categoryId = post.getCategory() == null ? null : post.getCategory().getId();
        String categoryName = post.getCategory() == null ? null : post.getCategory().getName();
        List<String> tags = splitTags(post.getTags());
        List<String> gallery = post.getImages().stream()
                .filter(image -> "GALLERY".equalsIgnoreCase(image.getImageType()))
                .sorted((a, b) -> Integer.compare(a.getSortOrder(), b.getSortOrder()))
                .map(PostImage::getImageUrl)
                .toList();
        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getSlug(),
                post.getExcerpt(),
                post.getContent(),
                post.getThumbnailUrl(),
                categoryId,
                categoryName,
                post.getAuthor(),
                post.getSource(),
                post.getSourceLink(),
                post.getArticleType(),
                post.getStatus(),
                post.getPublishedAt(),
                post.getSeoTitle(),
                post.getSeoDescription(),
                post.getMetaKeywords(),
                post.getSeoDescription(),
                post.getCanonicalUrl(),
                tags,
                gallery,
                new ArrayList<>(post.getRelatedPostIds()),
                post.getCreatedAt(),
                post.getUpdatedAt()
        );
    }

    private void replaceGallery(Post post, List<String> gallery) {
        post.getImages().clear();
        if (gallery == null) {
            return;
        }

        int index = 0;
        for (String imageUrl : gallery) {
            String normalized = MapperUtils.nullable(imageUrl);
            if (normalized == null) {
                continue;
            }
            PostImage image = new PostImage();
            image.setPost(post);
            image.setImageUrl(normalized);
            image.setImageType("GALLERY");
            image.setSortOrder(index++);
            post.getImages().add(image);
        }
    }

    private void replaceRelatedPosts(Post post, List<Long> relatedPostIds) {
        post.getRelatedPostIds().clear();
        if (relatedPostIds != null) {
            post.getRelatedPostIds().addAll(new LinkedHashSet<>(relatedPostIds.stream()
                    .filter(id -> id != null)
                    .toList()));
        }
    }

    private String joinTags(List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return null;
        }
        String joined = String.join(",", tags.stream()
                .map(MapperUtils::nullable)
                .filter(tag -> tag != null && !tag.isBlank())
                .toList());
        return joined.isBlank() ? null : joined;
    }

    private List<String> splitTags(String tags) {
        String normalized = MapperUtils.nullable(tags);
        if (normalized == null) {
            return List.of();
        }
        return Arrays.stream(normalized.split(","))
                .map(String::trim)
                .filter(tag -> !tag.isBlank())
                .toList();
    }

    private String firstNonBlank(String first, String second) {
        return MapperUtils.nullable(first) != null ? first : second;
    }
}
