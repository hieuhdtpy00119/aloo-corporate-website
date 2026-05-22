package com.aloo.cms.repository;

import com.aloo.cms.entity.CustomerUser;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerUserRepository extends JpaRepository<CustomerUser, Long> {

    Optional<CustomerUser> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);
}
