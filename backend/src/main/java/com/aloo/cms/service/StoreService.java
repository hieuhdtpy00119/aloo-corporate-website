package com.aloo.cms.service;

import com.aloo.cms.dto.StoreRequest;
import com.aloo.cms.dto.StoreResponse;
import com.aloo.cms.entity.Store;
import com.aloo.cms.entity.StoreBusinessHour;
import com.aloo.cms.entity.StoreGallery;
import com.aloo.cms.entity.StoreMenuPoster;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.StoreMapper;
import com.aloo.cms.repository.StoreRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StoreService {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {
    };
    private static final TypeReference<List<Map<String, Object>>> MAP_LIST = new TypeReference<>() {
    };

    private final StoreRepository storeRepository;
    private final StoreMapper storeMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<StoreResponse> findAll(String province, String status, Boolean featured) {
        return storeRepository.findAll(filterStores(province, status, featured), defaultSort())
                .stream()
                .map(storeMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<StoreResponse> findFeatured() {
        return storeRepository.findByFeaturedTrueAndStatusOrderByDisplayOrderAscIdAsc("ACTIVE")
                .stream()
                .map(storeMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public StoreResponse findBySlug(String slug) {
        return storeMapper.toResponse(storeRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Store not found")));
    }

    @Transactional
    public StoreResponse create(StoreRequest request) {
        validateUnique(request, null);
        Store store = storeMapper.toEntity(request);
        syncChildren(store, request);
        StoreResponse response = storeMapper.toResponse(storeRepository.save(store));
        auditLogService.logCreated("STORE", String.valueOf(response.id()), response.name(), response.slug());
        return response;
    }

    @Transactional
    public StoreResponse update(Long id, StoreRequest request) {
        Store store = getStore(id);
        validateUnique(request, id);
        storeMapper.updateEntity(store, request);
        syncChildren(store, request);
        StoreResponse response = storeMapper.toResponse(storeRepository.save(store));
        auditLogService.logUpdated("STORE", String.valueOf(response.id()), response.name(), response.slug());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        Store store = getStore(id);
        auditLogService.logDeleted("STORE", String.valueOf(store.getId()), store.getName(), store.getSlug());
        storeRepository.delete(store);
    }

    private Store getStore(Long id) {
        return storeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Store not found"));
    }

    private void validateUnique(StoreRequest request, Long id) {
        long currentId = id == null ? -1L : id;
        if (storeRepository.existsBySlugAndIdNot(request.slug().trim().toLowerCase(), currentId)) {
            throw new BadRequestException("Store slug is already used");
        }
        if (storeRepository.existsByStoreCodeAndIdNot(request.storeCode().trim(), currentId)) {
            throw new BadRequestException("Store code is already used");
        }
    }

    private Sort defaultSort() {
        return Sort.by("displayOrder").ascending().and(Sort.by("id").ascending());
    }

    private Specification<Store> filterStores(String province, String status, Boolean featured) {
        return (root, query, builder) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (province != null && !province.isBlank()) {
                predicates.add(builder.equal(root.get("province"), province.trim()));
            }
            if (status != null && !status.isBlank()) {
                predicates.add(builder.equal(root.get("status"), status.trim().toUpperCase()));
            }
            if (featured != null) {
                predicates.add(builder.equal(root.get("featured"), featured));
            }
            return builder.and(predicates.toArray(Predicate[]::new));
        };
    }

    private void syncChildren(Store store, StoreRequest request) {
        syncGallery(store, request.galleryJson());
        syncMenuPosters(store, request.menuPostersJson());
        syncBusinessHours(store, request.openingHours());
    }

    private void syncGallery(Store store, String galleryJson) {
        store.getGallery().clear();
        readStringList(galleryJson).forEach(url -> {
            if (url == null || url.isBlank()) return;
            StoreGallery image = new StoreGallery();
            image.setStore(store);
            image.setImageUrl(url.trim());
            image.setAltText(store.getName());
            image.setSortOrder(store.getGallery().size());
            store.getGallery().add(image);
        });
    }

    private void syncMenuPosters(Store store, String menuPostersJson) {
        store.getMenuPosters().clear();
        readMapList(menuPostersJson).forEach(item -> {
            String imageUrl = stringValue(item.get("imageUrl"));
            if (imageUrl == null) return;
            StoreMenuPoster poster = new StoreMenuPoster();
            poster.setStore(store);
            poster.setTitle(stringValue(item.get("title")) == null ? "Menu ALOO" : stringValue(item.get("title")));
            poster.setImageUrl(imageUrl);
            poster.setSortOrder(numberValue(item.get("sortOrder"), store.getMenuPosters().size()));
            poster.setActive(booleanValue(item.get("isActive"), true));
            store.getMenuPosters().add(poster);
        });
    }

    private void syncBusinessHours(Store store, String openingHours) {
        store.getBusinessHours().clear();
        if (openingHours == null || openingHours.isBlank()) {
            return;
        }
        StoreBusinessHour hour = new StoreBusinessHour();
        hour.setStore(store);
        hour.setDayOfWeek(0);
        hour.setOpenTime(parseTime(openingHours, 0));
        hour.setCloseTime(parseTime(openingHours, 1));
        hour.setClosed(false);
        store.getBusinessHours().add(hour);
    }

    private List<String> readStringList(String json) {
        if (json == null || json.isBlank()) return List.of();
        try {
            return OBJECT_MAPPER.readValue(json, STRING_LIST);
        } catch (Exception ex) {
            return List.of();
        }
    }

    private List<Map<String, Object>> readMapList(String json) {
        if (json == null || json.isBlank()) return List.of();
        try {
            return OBJECT_MAPPER.readValue(json, MAP_LIST);
        } catch (Exception ex) {
            return List.of();
        }
    }

    private LocalTime parseTime(String value, int index) {
        String[] parts = value.split("-");
        if (parts.length <= index) return null;
        try {
            return LocalTime.parse(parts[index].trim());
        } catch (Exception ex) {
            return null;
        }
    }

    private String stringValue(Object value) {
        if (value == null) return null;
        String text = String.valueOf(value).trim();
        return text.isEmpty() ? null : text;
    }

    private int numberValue(Object value, int fallback) {
        try {
            return value == null ? fallback : Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    private boolean booleanValue(Object value, boolean fallback) {
        return value == null ? fallback : Boolean.parseBoolean(String.valueOf(value));
    }
}
