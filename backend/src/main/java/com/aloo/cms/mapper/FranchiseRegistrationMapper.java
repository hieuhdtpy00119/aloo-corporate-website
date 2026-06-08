package com.aloo.cms.mapper;

import com.aloo.cms.dto.FranchiseRegistrationRequest;
import com.aloo.cms.dto.FranchiseRegistrationResponse;
import com.aloo.cms.entity.FranchiseRegistration;
import org.springframework.stereotype.Component;

@Component
public class FranchiseRegistrationMapper {

    public FranchiseRegistration toEntity(FranchiseRegistrationRequest request) {
        FranchiseRegistration registration = new FranchiseRegistration();
        registration.setFullName(MapperUtils.required(request.fullName()));
        registration.setPhone(MapperUtils.required(request.phone()));
        registration.setEmail(MapperUtils.nullable(request.email()));
        registration.setProvince(MapperUtils.required(request.province()));
        registration.setExpectedBudget(request.expectedBudget());
        registration.setNote(MapperUtils.nullable(request.note()));
        registration.setStatus("NEW");
        return registration;
    }

    public FranchiseRegistrationResponse toResponse(FranchiseRegistration registration) {
        return new FranchiseRegistrationResponse(
                registration.getId(),
                registration.getFullName(),
                registration.getPhone(),
                registration.getEmail(),
                registration.getProvince(),
                registration.getExpectedBudget(),
                registration.getNote(),
                registration.getLastContactedAt(),
                registration.getAssignedTo(),
                registration.getStatus(),
                registration.getCreatedAt(),
                registration.getUpdatedAt()
        );
    }
}
