package com.aloo.cms.repository;

import com.aloo.cms.entity.BrandTimeline;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BrandTimelineRepository extends JpaRepository<BrandTimeline, Long> {

    List<BrandTimeline> findAllByStatusIgnoreCase(String status, Sort sort);
}
