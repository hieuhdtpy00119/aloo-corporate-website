package com.aloo.cms.repository;

import com.aloo.cms.entity.HomeSection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Sort;

public interface HomeSectionRepository extends JpaRepository<HomeSection, Long> {
    List<HomeSection> findByStatus(String status, Sort sort);
}
