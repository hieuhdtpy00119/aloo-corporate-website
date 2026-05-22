package com.aloo.cms.service;

import com.aloo.cms.dto.LocationRequest;
import com.aloo.cms.dto.LocationResponse;
import com.aloo.cms.entity.Location;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.LocationMapper;
import com.aloo.cms.repository.LocationRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LocationService {

    private final LocationRepository locationRepository;
    private final LocationMapper locationMapper;

    @Transactional(readOnly = true)
    public List<LocationResponse> findAll() {
        return locationRepository.findAll(Sort.by("displayOrder").ascending()
                        .and(Sort.by("id").ascending()))
                .stream()
                .map(locationMapper::toResponse)
                .toList();
    }

    @Transactional
    public LocationResponse create(LocationRequest request) {
        Location location = locationMapper.toEntity(request);
        return locationMapper.toResponse(locationRepository.save(location));
    }

    @Transactional
    public LocationResponse update(Long id, LocationRequest request) {
        Location location = getLocation(id);
        locationMapper.updateEntity(location, request);
        return locationMapper.toResponse(locationRepository.save(location));
    }

    @Transactional
    public void delete(Long id) {
        Location location = getLocation(id);
        locationRepository.delete(location);
    }

    private Location getLocation(Long id) {
        return locationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Location not found"));
    }
}
