package com.aloo.cms.mapper;

import com.aloo.cms.dto.StoreRequest;
import com.aloo.cms.dto.StoreResponse;
import com.aloo.cms.entity.Store;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class StoreMapper {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {
    };
    private static final TypeReference<List<Map<String, Object>>> LINK_LIST = new TypeReference<>() {
    };

    public Store toEntity(StoreRequest request) {
        Store store = new Store();
        updateEntity(store, request);
        return store;
    }

    public void updateEntity(Store store, StoreRequest request) {
        store.setStoreCode(MapperUtils.required(request.storeCode()));
        store.setName(MapperUtils.required(request.name()));
        store.setSlug(MapperUtils.slug(request.slug()));
        store.setAddress(MapperUtils.required(request.address()));
        store.setProvince(MapperUtils.required(request.province()));
        store.setDistrict(MapperUtils.nullable(request.district()));
        store.setWard(MapperUtils.nullable(request.ward()));
        store.setLatitude(request.latitude());
        store.setLongitude(request.longitude());
        store.setPhone(MapperUtils.nullable(request.phone()));
        store.setEmail(MapperUtils.nullable(request.email()));
        store.setGoogleMapUrl(MapperUtils.nullable(firstNonBlank(request.googleMapUrl(), firstLinkUrl(readLinks(request.linksJson()), "GOOGLE_MAPS"))));
        store.setStoreType(MapperUtils.status(request.storeType(), "STANDARD"));
        store.setDescription(MapperUtils.nullable(request.description()));
        store.setCoverImageUrl(MapperUtils.nullable(request.coverImageUrl()));
        store.setFeatured(Boolean.TRUE.equals(request.featured()));
        store.setDisplayOrder(request.displayOrder() == null ? 0 : request.displayOrder());
        store.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public StoreResponse toResponse(Store store) {
        List<String> amenities = List.of();
        List<Map<String, Object>> links = store.getGoogleMapUrl() == null
                ? List.of()
                : List.of(Map.of("type", "GOOGLE_MAPS", "title", "Xem bản đồ", "url", store.getGoogleMapUrl()));
        String openingHours = store.getBusinessHours().stream()
                .filter(hour -> !Boolean.TRUE.equals(hour.getClosed()))
                .findFirst()
                .map(hour -> formatTime(hour.getOpenTime()) + " - " + formatTime(hour.getCloseTime()))
                .orElse(null);
        return new StoreResponse(
                store.getId(),
                store.getStoreCode(),
                store.getName(),
                store.getSlug(),
                store.getAddress(),
                store.getAddress(),
                store.getProvince(),
                store.getProvince(),
                store.getDistrict(),
                store.getWard(),
                store.getLatitude(),
                store.getLongitude(),
                store.getPhone(),
                store.getEmail(),
                openingHours,
                store.getGoogleMapUrl(),
                store.getStoreType(),
                store.getDescription(),
                store.getCoverImageUrl(),
                store.getCoverImageUrl(),
                toGalleryJson(store),
                "[]",
                toMenuPostersJson(store),
                links.isEmpty() ? "[]" : jsonOrDefault(writeJson(links), "[]"),
                store.getGoogleMapUrl(),
                amenities,
                links,
                store.getGallery().stream()
                        .map(image -> Map.<String, Object>of(
                                "id", image.getId() == null ? 0 : image.getId(),
                                "imageUrl", image.getImageUrl(),
                                "altText", image.getAltText() == null ? "" : image.getAltText(),
                                "sortOrder", image.getSortOrder()))
                        .toList(),
                store.getBusinessHours().stream()
                        .map(hour -> Map.<String, Object>of(
                                "id", hour.getId() == null ? 0 : hour.getId(),
                                "dayOfWeek", hour.getDayOfWeek(),
                                "openTime", hour.getOpenTime() == null ? "" : hour.getOpenTime().toString(),
                                "closeTime", hour.getCloseTime() == null ? "" : hour.getCloseTime().toString(),
                                "isClosed", Boolean.TRUE.equals(hour.getClosed())))
                        .toList(),
                store.getMenuPosters().stream()
                        .map(poster -> Map.<String, Object>of(
                                "id", poster.getId() == null ? 0 : poster.getId(),
                                "title", poster.getTitle(),
                                "imageUrl", poster.getImageUrl(),
                                "sortOrder", poster.getSortOrder(),
                                "isActive", Boolean.TRUE.equals(poster.getActive())))
                        .toList(),
                store.getFeatured(),
                store.getDisplayOrder(),
                store.getStatus(),
                store.getCreatedAt(),
                store.getUpdatedAt()
        );
    }

    private String jsonOrDefault(String value, String defaultValue) {
        String normalized = MapperUtils.nullable(value);
        return normalized == null ? defaultValue : normalized;
    }

    private String firstNonBlank(String first, String second) {
        String normalizedFirst = MapperUtils.nullable(first);
        return normalizedFirst == null ? MapperUtils.nullable(second) : normalizedFirst;
    }

    private String formatTime(java.time.LocalTime time) {
        return time == null ? "" : time.toString();
    }

    private String writeJson(Object value) {
        try {
            return OBJECT_MAPPER.writeValueAsString(value);
        } catch (JsonProcessingException ex) {
            return "[]";
        }
    }

    private String toGalleryJson(Store store) {
        return writeJson(store.getGallery().stream().map(image -> image.getImageUrl()).toList());
    }

    private String toMenuPostersJson(Store store) {
        return writeJson(store.getMenuPosters().stream()
                .map(poster -> Map.of("title", poster.getTitle(), "imageUrl", poster.getImageUrl()))
                .toList());
    }

    private List<String> readStringList(String json) {
        String normalized = MapperUtils.nullable(json);
        if (normalized == null) {
            return List.of();
        }
        try {
            return OBJECT_MAPPER.readValue(normalized, STRING_LIST);
        } catch (JsonProcessingException ex) {
            return List.of();
        }
    }

    private List<Map<String, Object>> readLinks(String json) {
        String normalized = MapperUtils.nullable(json);
        if (normalized == null) {
            return List.of();
        }
        try {
            return OBJECT_MAPPER.readValue(normalized, LINK_LIST);
        } catch (JsonProcessingException ex) {
            return List.of();
        }
    }

    private String firstLinkUrl(List<Map<String, Object>> links, String type) {
        String normalizedType = type.toUpperCase(Locale.ROOT);
        return links.stream()
                .filter(link -> normalizedType.equals(String.valueOf(link.getOrDefault("type", "")).toUpperCase(Locale.ROOT)))
                .map(link -> link.get("url"))
                .filter(String.class::isInstance)
                .map(String.class::cast)
                .findFirst()
                .orElse(null);
    }
}
