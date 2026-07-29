package com.aloo.cms.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.aloo.cms.dto.AccountStatusRequest;
import com.aloo.cms.dto.AccountUserRequest;
import com.aloo.cms.dto.AccountUserResponse;
import com.aloo.cms.dto.DemoteAdminRequest;
import com.aloo.cms.dto.PromoteCustomerRequest;
import com.aloo.cms.entity.AccountRoleHistory;
import com.aloo.cms.entity.AdminProfile;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AuthProvider;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ConflictException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.AccountRoleHistoryRepository;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.repository.ChatSessionRepository;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AccountManagementServiceTest {

    @Mock private AdminUserRepository adminUserRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private UserMapper userMapper;
    @Mock private AuditLogService auditLogService;
    @Mock private AdminEmailWhitelistService adminEmailWhitelistService;
    @Mock private MailNotificationService mailNotificationService;
    @Mock private AccountRoleHistoryRepository accountRoleHistoryRepository;
    @Mock private ChatSessionRepository chatSessionRepository;

    @InjectMocks private AccountManagementService service;

    @BeforeEach
    void mapSavedUsers() {
        lenient().when(adminUserRepository.save(any(AdminUser.class))).thenAnswer(invocation -> invocation.getArgument(0));
        lenient().when(userMapper.toAccountResponse(any(AdminUser.class))).thenAnswer(invocation -> response(invocation.getArgument(0)));
    }

    @Test
    void promotingCustomerChangesRoleAndRevokesExistingSessions() {
        AdminUser customer = user(11L, UserRole.USER, null, "ACTIVE", 3L, 7L);
        when(adminUserRepository.findById(11L)).thenReturn(Optional.of(customer));

        service.promoteCustomerToAdmin(11L, new PromoteCustomerRequest("CRM", "Phụ trách chăm sóc khách hàng", 3L));

        assertThat(customer.getRole()).isEqualTo(UserRole.ADMIN);
        assertThat(customer.getAdminProfile()).isEqualTo(AdminProfile.CRM);
        assertThat(customer.getSecurityVersion()).isEqualTo(8L);
        assertThat(customer.getRoleChangedAt()).isNotNull();
        verify(accountRoleHistoryRepository).save(any(AccountRoleHistory.class));
    }

    @Test
    void demotingAdminTransfersAssignedChatsAndRevokesSessions() {
        AdminUser source = user(20L, UserRole.ADMIN, AdminProfile.CRM, "ACTIVE", 2L, 1L);
        AdminUser recipient = user(21L, UserRole.ADMIN, AdminProfile.FULL, "ACTIVE", 0L, 0L);
        when(adminUserRepository.findById(20L)).thenReturn(Optional.of(source));
        when(adminUserRepository.findById(21L)).thenReturn(Optional.of(recipient));
        when(chatSessionRepository.countByAssignedAdminId(20L)).thenReturn(4L);

        service.demoteAdminToCustomer(20L, new DemoteAdminRequest("Điều chuyển công việc", 21L, 2L));

        assertThat(source.getRole()).isEqualTo(UserRole.USER);
        assertThat(source.getAdminProfile()).isNull();
        assertThat(source.getSecurityVersion()).isEqualTo(2L);
        verify(chatSessionRepository).transferAssignments(20L, 21L);
        verify(accountRoleHistoryRepository).save(any(AccountRoleHistory.class));
    }

    @Test
    void lastActiveSystemAdministratorCannotBeSuspended() {
        AdminUser lastSystemAdmin = user(30L, UserRole.ADMIN, AdminProfile.FULL, "ACTIVE", 0L, 0L);
        when(adminUserRepository.findById(30L)).thenReturn(Optional.of(lastSystemAdmin));
        when(adminUserRepository.lockActiveSystemAdmins()).thenReturn(List.of(lastSystemAdmin));

        assertThatThrownBy(() -> service.updateAdminStatus(
                30L,
                new AccountStatusRequest("SUSPENDED", "Tạm ngưng", 0L)
        )).isInstanceOf(BadRequestException.class)
                .hasMessageContaining("last active SYSTEM/FULL");

        verify(adminUserRepository, never()).save(lastSystemAdmin);
    }

    @Test
    void deactivatingCustomerRecordsReasonAndRevokesSessions() {
        AdminUser customer = user(40L, UserRole.USER, null, "ACTIVE", 5L, 9L);
        when(adminUserRepository.findById(40L)).thenReturn(Optional.of(customer));

        service.updateCustomerStatus(40L, new AccountStatusRequest("DEACTIVATED", "Khách yêu cầu đóng", 5L));

        assertThat(customer.getStatus()).isEqualTo("DEACTIVATED");
        assertThat(customer.getStatusReason()).isEqualTo("Khách yêu cầu đóng");
        assertThat(customer.getDeactivatedAt()).isNotNull();
        assertThat(customer.getSecurityVersion()).isEqualTo(10L);
    }

    @Test
    void staleAccountVersionIsRejectedBeforeMutation() {
        AdminUser customer = user(50L, UserRole.USER, null, "ACTIVE", 8L, 0L);
        when(adminUserRepository.findById(50L)).thenReturn(Optional.of(customer));

        assertThatThrownBy(() -> service.promoteCustomerToAdmin(
                50L,
                new PromoteCustomerRequest("FULL", "Nâng quyền", 7L)
        )).isInstanceOf(ConflictException.class);

        assertThat(customer.getRole()).isEqualTo(UserRole.USER);
        verify(adminUserRepository, never()).save(customer);
    }

    @Test
    void changingOnlyAdminProfileDoesNotRequireWhitelistReapproval() {
        AdminUser admin = user(60L, UserRole.ADMIN, AdminProfile.CRM, "ACTIVE", 4L, 2L);
        when(adminUserRepository.findById(60L)).thenReturn(Optional.of(admin));

        service.updateAdminUser(60L, new AccountUserRequest(
                admin.getEmail(),
                admin.getFullName(),
                null,
                null,
                null,
                "ACTIVE",
                "STORES",
                "Điều chỉnh phạm vi quản lý",
                4L
        ));

        assertThat(admin.getAdminProfile()).isEqualTo(AdminProfile.STORES);
        assertThat(admin.getSecurityVersion()).isEqualTo(3L);
        verify(adminEmailWhitelistService, never()).ensureAllowed(any());
    }

    private AdminUser user(
            Long id,
            UserRole role,
            AdminProfile profile,
            String status,
            Long version,
            Long securityVersion
    ) {
        AdminUser user = new AdminUser();
        user.setId(id);
        user.setEmail("user" + id + "@aloo.vn");
        user.setFullName("User " + id);
        user.setPasswordHash("encoded");
        user.setRole(role);
        user.setAdminProfile(profile);
        user.setStatus(status);
        user.setVersion(version);
        user.setSecurityVersion(securityVersion);
        user.setAuthProvider(AuthProvider.LOCAL);
        return user;
    }

    private AccountUserResponse response(AdminUser user) {
        return new AccountUserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getRole().name(),
                user.getAdminProfile() == null ? null : user.getAdminProfile().name(),
                List.of(),
                user.getStatus(),
                user.getAuthProvider().name(),
                user.getVersion(),
                user.getStatusReason(),
                user.getDeactivatedAt(),
                user.getRoleChangedAt(),
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
