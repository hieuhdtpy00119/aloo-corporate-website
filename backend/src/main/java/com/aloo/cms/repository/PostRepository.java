package com.aloo.cms.repository;

import com.aloo.cms.entity.Post;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, Long> {

    Optional<Post> findBySlug(String slug);

    Optional<Post> findBySlugAndStatusIgnoreCase(String slug, String status);

    List<Post> findByStatusIgnoreCase(String status, Sort sort);

    boolean existsBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Long id);
}
