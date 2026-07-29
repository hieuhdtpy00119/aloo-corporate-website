package com.aloo.cms.repository;

import com.aloo.cms.entity.AccountRoleHistory;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountRoleHistoryRepository extends JpaRepository<AccountRoleHistory, Long> {
    List<AccountRoleHistory> findByUserIdOrderByChangedAtDesc(Long userId);
}
