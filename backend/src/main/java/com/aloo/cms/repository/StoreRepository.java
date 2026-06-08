package com.aloo.cms.repository;

import com.aloo.cms.entity.Store;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface StoreRepository extends JpaRepository<Store, Long>, JpaSpecificationExecutor<Store> {

    Optional<Store> findBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Long id);

    boolean existsByStoreCodeAndIdNot(String storeCode, Long id);

    List<Store> findByFeaturedTrueAndStatusOrderByDisplayOrderAscIdAsc(String status);
}
