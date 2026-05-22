package com.aloo.cms.repository;

import com.aloo.cms.entity.Category;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    Optional<Category> findFirstByNameIgnoreCase(String name);

    Optional<Category> findFirstByTypeAndNameIgnoreCase(String type, String name);

    Optional<Category> findByTypeAndSlug(String type, String slug);

    boolean existsByTypeAndSlug(String type, String slug);

    boolean existsByTypeAndSlugAndIdNot(String type, String slug, Long id);
}
