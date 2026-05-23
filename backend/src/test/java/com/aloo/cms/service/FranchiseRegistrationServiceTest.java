package com.aloo.cms.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.aloo.cms.dto.FranchiseRegistrationRequest;
import com.aloo.cms.dto.FranchiseRegistrationResponse;
import com.aloo.cms.dto.RegistrationStatusUpdateRequest;
import com.aloo.cms.entity.FranchiseRegistration;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.FranchiseRegistrationMapper;
import com.aloo.cms.repository.FranchiseRegistrationRepository;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class FranchiseRegistrationServiceTest {

    @Mock
    private FranchiseRegistrationRepository registrationRepository;

    @Test
    void createStoresNewLeadWithDefaultStatus() {
        FranchiseRegistrationService service = new FranchiseRegistrationService(
                registrationRepository,
                new FranchiseRegistrationMapper()
        );

        when(registrationRepository.save(any(FranchiseRegistration.class))).thenAnswer(invocation -> {
            FranchiseRegistration registration = invocation.getArgument(0);
            registration.setId(11L);
            return registration;
        });

        FranchiseRegistrationResponse response = service.create(new FranchiseRegistrationRequest(
                "Nguyen Van A",
                "0900123456",
                "a@example.com",
                "TP.HCM",
                BigDecimal.valueOf(300_000_000),
                "Can tu van"
        ));

        assertThat(response.id()).isEqualTo(11L);
        assertThat(response.fullName()).isEqualTo("Nguyen Van A");
        assertThat(response.status()).isEqualTo("NEW");
    }

    @Test
    void updateStatusUppercasesAndRejectsMissingLead() {
        FranchiseRegistrationService service = new FranchiseRegistrationService(
                registrationRepository,
                new FranchiseRegistrationMapper()
        );

        FranchiseRegistration registration = new FranchiseRegistration();
        registration.setId(12L);
        registration.setFullName("Tran Thi B");
        registration.setPhone("0900111222");
        registration.setProvince("Da Nang");
        registration.setStatus("NEW");

        when(registrationRepository.findById(12L)).thenReturn(Optional.of(registration));
        when(registrationRepository.save(any(FranchiseRegistration.class))).thenAnswer(invocation -> invocation.getArgument(0));

        FranchiseRegistrationResponse response = service.updateStatus(
                12L,
                new RegistrationStatusUpdateRequest("contacted")
        );

        assertThat(response.status()).isEqualTo("CONTACTED");

        when(registrationRepository.findById(404L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.findById(404L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Franchise registration not found");
    }
}
