package com.aloo.cms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.List;

public record PostRequest(
        @NotBlank(message = "Post title is required")
        @Size(max = 260, message = "Post title must be at most 260 characters")
        String title,

        @NotBlank(message = "Post slug is required")
        @Size(max = 280, message = "Post slug must be at most 280 characters")
        String slug,

        @Size(max = 1000, message = "Excerpt must be at most 1000 characters")
        String excerpt,

        String content,

        @Size(max = 600, message = "Thumbnail URL must be at most 600 characters")
        String thumbnailUrl,

        Long categoryId,

        @Size(max = 180, message = "Category must be at most 180 characters")
        String category,

        @Size(max = 180, message = "Author must be at most 180 characters")
        String author,

        @Size(max = 180, message = "Source must be at most 180 characters")
        String source,

        @Size(max = 600, message = "Source link must be at most 600 characters")
        String sourceLink,

        @Size(max = 120, message = "Article type must be at most 120 characters")
        String articleType,

        @Size(max = 40, message = "Status must be at most 40 characters")
        String status,

        LocalDateTime publishedAt,

        @Size(max = 260, message = "SEO title must be at most 260 characters")
        String seoTitle,

        @Size(max = 500, message = "SEO description must be at most 500 characters")
        String seoDescription,

        @Size(max = 500, message = "Meta keywords must be at most 500 characters")
        String metaKeywords,

        @Size(max = 500, message = "Meta description must be at most 500 characters")
        String metaDescription,

        @Size(max = 600, message = "Canonical URL must be at most 600 characters")
        String canonicalUrl,

        List<String> tags,

        List<String> gallery,

        List<Long> relatedPostIds
) {
}
