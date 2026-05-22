package com.aloo.cms.mapper;

import com.aloo.cms.dto.LocationRequest;
import com.aloo.cms.dto.LocationResponse;
import com.aloo.cms.entity.Location;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class LocationMapper {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {
    };

    public Location toEntity(LocationRequest request) {
        Location location = new Location();
        updateEntity(location, request);
        return location;
    }

    public void updateEntity(Location location, LocationRequest request) {
        location.setName(MapperUtils.required(request.name()));
        location.setAddress(MapperUtils.required(request.address()));
        location.setProvince(MapperUtils.required(request.province()));
        location.setDistrict(MapperUtils.nullable(request.district()));
        location.setPhone(MapperUtils.nullable(request.phone()));
        location.setOpeningHours(MapperUtils.nullable(request.openingHours()));
        location.setMapUrl(MapperUtils.nullable(request.mapUrl()));
        location.setImageUrl(MapperUtils.nullable(request.imageUrl()));
        location.setAmenitiesJson(writeAmenities(request.amenities()));
        location.setDisplayOrder(request.displayOrder() == null ? 0 : request.displayOrder());
        location.setFeatured(Boolean.TRUE.equals(request.featured()));
        location.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public LocationResponse toResponse(Location location) {
        return new LocationResponse(
                location.getId(),
                location.getName(),
                location.getAddress(),
                location.getAddress(),
                location.getProvince(),
                location.getProvince(),
                location.getDistrict(),
                location.getPhone(),
                location.getOpeningHours(),
                location.getMapUrl(),
                location.getImageUrl(),
                readAmenities(location.getAmenitiesJson()),
                location.getDisplayOrder(),
                location.getFeatured(),
                location.getStatus(),
                location.getCreatedAt(),
                location.getUpdatedAt()
        );
    }

    private String writeAmenities(List<String> amenities) {
        if (amenities == null || amenities.isEmpty()) {
            return null;
        }
        try {
            return OBJECT_MAPPER.writeValueAsString(amenities);
        } catch (JsonProcessingException ex) {
            return null;
        }
    }

    private List<String> readAmenities(String amenitiesJson) {
        String normalized = MapperUtils.nullable(amenitiesJson);
        if (normalized == null) {
            return List.of();
        }
        try {
            return OBJECT_MAPPER.readValue(normalized, STRING_LIST);
        } catch (JsonProcessingException ex) {
            return List.of();
        }
    }
}
