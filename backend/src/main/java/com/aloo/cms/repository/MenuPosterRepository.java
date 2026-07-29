package com.aloo.cms.repository;

import com.aloo.cms.entity.MenuPoster;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MenuPosterRepository extends JpaRepository<MenuPoster, Long> {

    Optional<MenuPoster> findByBranchKey(String branchKey);

    List<MenuPoster> findByStatusIgnoreCase(String status, Sort sort);

    boolean existsByBranchKey(String branchKey);

    boolean existsByBranchKeyAndIdNot(String branchKey, Long id);
}
