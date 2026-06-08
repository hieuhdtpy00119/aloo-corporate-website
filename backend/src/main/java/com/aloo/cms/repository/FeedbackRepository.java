package com.aloo.cms.repository;

import com.aloo.cms.entity.Feedback;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    List<Feedback> findByVisibleTrue(Sort sort);
}
