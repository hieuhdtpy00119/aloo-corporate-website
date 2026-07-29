package com.aloo.cms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.CascadeType;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "posts")
public class Post {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 260)
    private String title;

    @Column(nullable = false, unique = true, length = 280)
    private String slug;

    @Column(length = 1000)
    private String excerpt;

    @Column(columnDefinition = "text")
    private String content;

    @Column(length = 600)
    private String thumbnailUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(length = 180)
    private String author;

    @Column(length = 180)
    private String source;

    @Column(length = 600)
    private String sourceLink;

    @Column(length = 120)
    private String articleType;

    @Column(nullable = false, length = 40)
    private String status = "DRAFT";

    private LocalDateTime publishedAt;

    @Column(length = 260)
    private String seoTitle;

    @Column(length = 500)
    private String seoDescription;

    @Column(length = 500)
    private String metaKeywords;

    @Column(length = 600)
    private String canonicalUrl;

    @Column(length = 500)
    private String tags;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PostImage> images = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "post_related_posts", joinColumns = @JoinColumn(name = "post_id"))
    @Column(name = "related_post_id")
    private Set<Long> relatedPostIds = new LinkedHashSet<>();

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
