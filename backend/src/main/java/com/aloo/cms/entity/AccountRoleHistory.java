package com.aloo.cms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "account_role_history")
public class AccountRoleHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private Long userId;
    @Column(nullable = false, length = 30)
    private String fromRole;
    @Column(nullable = false, length = 30)
    private String toRole;
    @Column(length = 30)
    private String fromAdminProfile;
    @Column(length = 30)
    private String toAdminProfile;
    @Column(nullable = false, length = 500)
    private String reason;
    @Column(nullable = false, length = 180)
    private String changedBy;
    @Column(nullable = false)
    private LocalDateTime changedAt;

    @PrePersist
    void prePersist() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}
