package com.aloo.cms.repository;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminUserRepository extends JpaRepository<AdminUser, Long>, JpaSpecificationExecutor<AdminUser> {

    Optional<AdminUser> findByEmailIgnoreCase(String email);

    Optional<AdminUser> findFirstByPhoneIgnoreCase(String phone);

    Optional<AdminUser> findByEmailIgnoreCaseAndRole(String email, UserRole role);

    List<AdminUser> findAllByRole(UserRole role, Sort sort);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);

    long countByRoleAndStatusIgnoreCase(UserRole role, String status);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT user FROM AdminUser user
            WHERE user.role = com.aloo.cms.entity.UserRole.ADMIN
              AND UPPER(user.status) = 'ACTIVE'
              AND (user.adminProfile IS NULL OR user.adminProfile IN (
                  com.aloo.cms.entity.AdminProfile.FULL,
                  com.aloo.cms.entity.AdminProfile.SYSTEM
              ))
            """)
    List<AdminUser> lockActiveSystemAdmins();
}
