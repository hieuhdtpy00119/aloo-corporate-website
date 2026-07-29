package com.aloo.cms.repository;

import com.aloo.cms.entity.FranchiseContent;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FranchiseContentRepository extends JpaRepository<FranchiseContent, Long> {

    List<FranchiseContent> findByStatusIgnoreCase(String status, Sort sort);
}
