package com.aloo.cms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "home_sections")
public class HomeSection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 120)
    private String sectionKey;

    @Column(nullable = false, length = 60)
    private String type = "FEATURED_CARD";

    @Column(nullable = false, length = 220)
    private String title;

    @Column(length = 180)
    private String subtitle;

    @Column(columnDefinition = "text")
    private String description;

    @Column(length = 600)
    private String imageUrl;

    @Column(length = 120)
    private String buttonText;

    @Column(length = 600)
    private String buttonLink;

    @Column(length = 160)
    private String badge;

    @Column(nullable = false)
    private Integer sortOrder = 0;

    @Column(nullable = false, length = 40)
    private String status = "ACTIVE";

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
