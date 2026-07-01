package com.aloo.cms.repository;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminUserRepository extends JpaRepository<AdminUser, Long> {

    Optional<AdminUser> findByEmailIgnoreCase(String email);

    Optional<AdminUser> findFirstByPhoneIgnoreCase(String phone);

    Optional<AdminUser> findByEmailIgnoreCaseAndRole(String email, UserRole role);

    List<AdminUser> findAllByRole(UserRole role, Sort sort);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);

    long countByRoleAndStatusIgnoreCase(UserRole role, String status);
}
