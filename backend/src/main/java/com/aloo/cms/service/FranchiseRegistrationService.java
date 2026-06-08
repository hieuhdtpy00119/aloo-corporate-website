package com.aloo.cms.service;

import com.aloo.cms.dto.FranchiseRegistrationRequest;
import com.aloo.cms.dto.FranchiseRegistrationResponse;
import com.aloo.cms.dto.RegistrationStatusUpdateRequest;
import com.aloo.cms.entity.FranchiseRegistration;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.FranchiseRegistrationMapper;
import com.aloo.cms.repository.FranchiseRegistrationRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FranchiseRegistrationService {

    private static final List<String> STATUSES = List.of("NEW", "CONTACTED", "CONSULTING", "POTENTIAL", "SIGNED", "REJECTED");

    private final FranchiseRegistrationRepository registrationRepository;
    private final FranchiseRegistrationMapper registrationMapper;

    @Transactional
    public FranchiseRegistrationResponse create(FranchiseRegistrationRequest request) {
        FranchiseRegistration registration = registrationRepository.save(registrationMapper.toEntity(request));
        return registrationMapper.toResponse(registration);
    }

    @Transactional(readOnly = true)
    public List<FranchiseRegistrationResponse> findAll() {
        return registrationRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(registrationMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public FranchiseRegistrationResponse findById(Long id) {
        return registrationMapper.toResponse(getRegistration(id));
    }

    @Transactional
    public FranchiseRegistrationResponse updateStatus(Long id, RegistrationStatusUpdateRequest request) {
        FranchiseRegistration registration = getRegistration(id);
        registration.setStatus(normalizeStatus(request.status()));
        if (request.note() != null) {
            registration.setNote(request.note().trim());
        }
        if (request.assignedTo() != null) {
            registration.setAssignedTo(request.assignedTo().trim());
        }
        if (request.lastContactedAt() != null && !request.lastContactedAt().isBlank()) {
            registration.setLastContactedAt(LocalDateTime.parse(request.lastContactedAt().trim()));
        }
        return registrationMapper.toResponse(registrationRepository.save(registration));
    }

    @Transactional
    public void delete(Long id) {
        FranchiseRegistration registration = getRegistration(id);
        registrationRepository.delete(registration);
    }

    private FranchiseRegistration getRegistration(Long id) {
        return registrationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Franchise registration not found"));
    }

    private String normalizeStatus(String status) {
        String normalized = status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
        if ("DONE".equals(normalized) || "COMPLETED".equals(normalized)) {
            return "SIGNED";
        }
        if ("CANCELED".equals(normalized) || "CANCELLED".equals(normalized)) {
            return "REJECTED";
        }
        if (!STATUSES.contains(normalized)) {
            throw new IllegalArgumentException("Franchise registration status is invalid");
        }
        return normalized;
    }
}
