package com.aloo.cms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PostLoad;
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
@Table(name = "users")
public class AdminUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 180)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false, length = 180)
    private String fullName;

    @Column(length = 40)
    private String phone;

    @Column(length = 600)
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private UserRole role = UserRole.ADMIN;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private AdminProfile adminProfile = AdminProfile.FULL;

    @Column(nullable = false, length = 30)
    private String status = "ACTIVE";

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private AuthProvider authProvider = AuthProvider.LOCAL;

    private LocalDateTime passwordSetAt;

    private LocalDateTime lastLoginAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        ensureAuthProvider();
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = LocalDateTime.now();
        ensureAuthProvider();
    }

    @PostLoad
    void postLoad() {
        ensureAuthProvider();
    }

    private void ensureAuthProvider() {
        if (authProvider == null) {
            authProvider = AuthProvider.LOCAL;
        }
    }
}
