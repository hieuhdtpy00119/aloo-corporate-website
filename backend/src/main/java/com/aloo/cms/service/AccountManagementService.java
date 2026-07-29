package com.aloo.cms.service;

import com.aloo.cms.dto.AccountPasswordRequest;
import com.aloo.cms.dto.AccountPageResponse;
import com.aloo.cms.dto.DemoteAdminRequest;
import com.aloo.cms.dto.PromoteCustomerRequest;
import com.aloo.cms.dto.AccountStatusRequest;
import com.aloo.cms.dto.AccountUserRequest;
import com.aloo.cms.dto.AccountUserResponse;
import com.aloo.cms.entity.AdminProfile;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AccountRoleHistory;
import com.aloo.cms.entity.AuthProvider;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ConflictException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.repository.AccountRoleHistoryRepository;
import com.aloo.cms.repository.ChatSessionRepository;
import com.aloo.cms.security.CustomUserDetails;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.aloo.cms.support.PasswordPolicySupport;

@Service
@RequiredArgsConstructor
public class AccountManagementService {

    private static final List<String> ALLOWED_STATUSES = List.of(
            "INVITED", "ACTIVE", "SUSPENDED", "LOCKED", "DEACTIVATED"
    );

    private final AdminUserRepository adminUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final AuditLogService auditLogService;
    private final AdminEmailWhitelistService adminEmailWhitelistService;
    private final MailNotificationService mailNotificationService;
    private final AccountRoleHistoryRepository accountRoleHistoryRepository;
    private final ChatSessionRepository chatSessionRepository;

    @Transactional(readOnly = true)
    public AccountPageResponse searchAccounts(
            String role,
            String status,
            String adminProfile,
            String authProvider,
            String query,
            int page,
            int size
    ) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        Specification<AdminUser> spec = Specification.where(null);

        if (role != null && !role.isBlank()) {
            UserRole parsedRole;
            try {
                parsedRole = UserRole.valueOf(role.trim().toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException ex) {
                throw new BadRequestException("Account role is invalid");
            }
            spec = spec.and((root, criteria, cb) -> cb.equal(root.get("role"), parsedRole));
        }
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            String parsedStatus = normalizeStatus(status);
            spec = spec.and((root, criteria, cb) -> cb.equal(cb.upper(root.get("status")), parsedStatus));
        }
        if (adminProfile != null && !adminProfile.isBlank() && !"ALL".equalsIgnoreCase(adminProfile)) {
            AdminProfile profile = normalizeAdminProfile(adminProfile);
            spec = spec.and((root, criteria, cb) -> cb.equal(root.get("adminProfile"), profile));
        }
        if (authProvider != null && !authProvider.isBlank() && !"ALL".equalsIgnoreCase(authProvider)) {
            AuthProvider provider;
            try {
                provider = AuthProvider.valueOf(authProvider.trim().toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException ex) {
                throw new BadRequestException("Authentication provider is invalid");
            }
            spec = spec.and((root, criteria, cb) -> cb.equal(root.get("authProvider"), provider));
        }
        if (query != null && !query.isBlank()) {
            String keyword = "%" + query.trim().toLowerCase(Locale.ROOT) + "%";
            spec = spec.and((root, criteria, cb) -> cb.or(
                    cb.like(cb.lower(root.get("email")), keyword),
                    cb.like(cb.lower(root.get("fullName")), keyword),
                    cb.like(cb.lower(cb.coalesce(root.get("phone"), "")), keyword)
            ));
        }

        Page<AdminUser> result = adminUserRepository.findAll(
                spec,
                PageRequest.of(safePage, safeSize, defaultSort())
        );
        return new AccountPageResponse(
                result.getContent().stream().map(userMapper::toAccountResponse).toList(),
                result.getTotalElements(),
                result.getTotalPages(),
                result.getNumber(),
                result.getSize()
        );
    }

    @Transactional(readOnly = true)
    public List<AccountUserResponse> findAdminUsers() {
        return findByRole(UserRole.ADMIN);
    }

    @Transactional(readOnly = true)
    public List<AccountUserResponse> findCustomerUsers() {
        return findByRole(UserRole.USER);
    }

    @Transactional
    public AccountUserResponse createAdminUser(AccountUserRequest request) {
        adminEmailWhitelistService.ensureAllowed(normalizeEmail(request.email()));
        AccountUserResponse response = createUser(request, UserRole.ADMIN);
        auditLogService.log(
                "CREATE_ADMIN",
                "ADMIN_USER",
                String.valueOf(response.id()),
                "Created admin account " + response.email() + " with profile " + response.adminProfile()
        );
        return response;
    }

    @Transactional
    public AccountUserResponse updateAdminUser(Long id, AccountUserRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        verifyVersion(user, request.expectedVersion());
        String normalizedEmail = normalizeEmail(request.email());
        if (!user.getEmail().equalsIgnoreCase(normalizedEmail)) {
            adminEmailWhitelistService.ensureAllowed(normalizedEmail);
        }
        AdminProfile priorProfile = effectiveProfile(user);
        updateCommonFields(user, request);
        if (priorProfile != effectiveProfile(user)) {
            ensureCanRemoveLastSystemAdmin(user, user.getStatus(), effectiveProfile(user), UserRole.ADMIN);
            String reason = sanitizeReason(request.changeReason());
            user.setSecurityVersion(nextSecurityVersion(user));
            user.setRoleChangedAt(LocalDateTime.now());
            user.setRoleChangedBy(currentActorEmail());
            AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
            recordRoleHistory(user, UserRole.ADMIN, priorProfile, UserRole.ADMIN, effectiveProfile(user), reason);
            auditLogService.log(
                    "UPDATE_ADMIN_PROFILE",
                    "ADMIN_USER",
                    String.valueOf(response.id()),
                    "Updated admin profile for " + response.email() + "; reason=" + reason
            );
            return response;
        }
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        auditLogService.log(
                "UPDATE_ADMIN",
                "ADMIN_USER",
                String.valueOf(response.id()),
                "Updated admin account " + response.email()
        );
        return response;
    }

    @Transactional
    public AccountUserResponse updateAdminStatus(Long id, AccountStatusRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        verifyVersion(user, request.expectedVersion());
        String status = normalizeStatus(request.status());
        ensureCanRemoveLastSystemAdmin(user, status, effectiveProfile(user), UserRole.ADMIN);
        ensureNotDeactivatingSelf(user, status);
        applyStatus(user, status, request.reason());
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        auditLogService.log(
                "UPDATE_ADMIN_STATUS",
                "ADMIN_USER",
                String.valueOf(response.id()),
                "Changed status to " + response.status()
        );
        return response;
    }

    @Transactional
    public void changeAdminPassword(Long id, AccountPasswordRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        changePassword(user, request);
        auditLogService.log(
                "CHANGE_ADMIN_PASSWORD",
                "ADMIN_USER",
                String.valueOf(user.getId()),
                "Password reset for " + user.getEmail()
        );
    }

    @Transactional
    public void deleteAdminUser(Long id) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        ensureNotDeletingSelf(user.getId());
        ensureCanRemoveLastSystemAdmin(user, "DEACTIVATED", effectiveProfile(user), UserRole.ADMIN);
        applyStatus(user, "DEACTIVATED", "Deactivated by system administrator");
        user.setDeactivatedAt(LocalDateTime.now());
        user.setDeactivatedBy(currentActorEmail());
        adminUserRepository.save(user);
        auditLogService.log(
                "DEACTIVATE_ADMIN",
                "ADMIN_USER",
                String.valueOf(user.getId()),
                "Deactivated admin account " + user.getEmail()
        );
    }

    @Transactional
    public AccountUserResponse createCustomerUser(AccountUserRequest request) {
        AccountUserResponse response = createUser(request, UserRole.USER);
        auditLogService.log(
                "CREATE_CUSTOMER",
                "CUSTOMER_USER",
                String.valueOf(response.id()),
                "Created customer account " + response.email()
        );
        return response;
    }

    @Transactional
    public AccountUserResponse updateCustomerUser(Long id, AccountUserRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        verifyVersion(user, request.expectedVersion());
        updateCommonFields(user, request);
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        auditLogService.log(
                "UPDATE_CUSTOMER",
                "CUSTOMER_USER",
                String.valueOf(response.id()),
                "Updated customer account " + response.email()
        );
        return response;
    }

    @Transactional
    public AccountUserResponse updateCustomerStatus(Long id, AccountStatusRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        verifyVersion(user, request.expectedVersion());
        applyStatus(user, normalizeStatus(request.status()), request.reason());
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        auditLogService.log(
                "UPDATE_CUSTOMER_STATUS",
                "CUSTOMER_USER",
                String.valueOf(response.id()),
                "Changed status to " + response.status()
        );
        return response;
    }

    @Transactional
    public void changeCustomerPassword(Long id, AccountPasswordRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        changePassword(user, request);
        auditLogService.log(
                "CHANGE_CUSTOMER_PASSWORD",
                "CUSTOMER_USER",
                String.valueOf(user.getId()),
                "Password reset for " + user.getEmail()
        );
    }

    @Transactional
    public void deleteCustomerUser(Long id) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        ensureNotDeletingSelf(user.getId());
        applyStatus(user, "DEACTIVATED", "Deactivated by system administrator");
        user.setDeactivatedAt(LocalDateTime.now());
        user.setDeactivatedBy(currentActorEmail());
        adminUserRepository.save(user);
        auditLogService.log(
                "DEACTIVATE_CUSTOMER",
                "CUSTOMER_USER",
                String.valueOf(user.getId()),
                "Deactivated customer account " + user.getEmail()
        );
    }

    @Transactional
    public AccountUserResponse promoteCustomerToAdmin(Long id, PromoteCustomerRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        verifyVersion(user, request.expectedVersion());
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new BadRequestException("Only active customer accounts can be promoted");
        }
        adminEmailWhitelistService.ensureAllowed(user.getEmail());

        AdminProfile newProfile = normalizeAdminProfile(request.adminProfile());
        user.setRole(UserRole.ADMIN);
        user.setAdminProfile(newProfile);
        user.setSecurityVersion(nextSecurityVersion(user));
        user.setRoleChangedAt(LocalDateTime.now());
        user.setRoleChangedBy(currentActorEmail());
        if (usesGoogleSignIn(user)) {
            user.setAuthProvider(AuthProvider.GOOGLE);
        }
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        recordRoleHistory(user, UserRole.USER, null, UserRole.ADMIN, newProfile, request.reason());
        auditLogService.log(
                "PROMOTE_CUSTOMER",
                "ADMIN_USER",
                String.valueOf(response.id()),
                "Promoted customer " + response.email() + " to admin with profile " + response.adminProfile()
                        + "; reason=" + sanitizeReason(request.reason())
        );
        return response;
    }

    @Transactional
    public AccountUserResponse demoteAdminToCustomer(Long id, DemoteAdminRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        verifyVersion(user, request.expectedVersion());
        ensureNotDeletingSelf(user.getId());
        AdminProfile priorProfile = effectiveProfile(user);
        ensureCanRemoveLastSystemAdmin(user, user.getStatus(), null, UserRole.USER);
        transferChatAssignments(user, request.transferToAdminId());

        user.setRole(UserRole.USER);
        user.setAdminProfile(null);
        user.setSecurityVersion(nextSecurityVersion(user));
        user.setRoleChangedAt(LocalDateTime.now());
        user.setRoleChangedBy(currentActorEmail());
        AccountUserResponse response = userMapper.toAccountResponse(adminUserRepository.save(user));
        recordRoleHistory(user, UserRole.ADMIN, priorProfile, UserRole.USER, null, request.reason());
        auditLogService.log(
                "DEMOTE_ADMIN",
                "CUSTOMER_USER",
                String.valueOf(response.id()),
                "Demoted admin " + response.email() + " to customer; reason=" + sanitizeReason(request.reason())
        );
        return response;
    }

    private List<AccountUserResponse> findByRole(UserRole role) {
        return adminUserRepository.findAllByRole(role, defaultSort()).stream()
                .map(userMapper::toAccountResponse)
                .toList();
    }

    private AccountUserResponse createUser(AccountUserRequest request, UserRole role) {
        String email = normalizeEmail(request.email());
        ensureEmailAvailable(email, null);
        String password = requirePassword(request.password());
        PasswordPolicySupport.validateStrongPassword(password);

        AdminUser user = new AdminUser();
        user.setRole(role);
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setPasswordSetAt(java.time.LocalDateTime.now());
        user.setStatus(normalizeStatus(request.status()));
        if (role == UserRole.ADMIN) {
            user.setAdminProfile(normalizeAdminProfile(request.adminProfile()));
        }
        user.setAuthProvider(AuthProvider.LOCAL);
        setProfileFields(user, request);
        return userMapper.toAccountResponse(adminUserRepository.save(user));
    }

    private void updateCommonFields(AdminUser user, AccountUserRequest request) {
        String email = normalizeEmail(request.email());
        ensureEmailAvailable(email, user.getId());
        user.setEmail(email);
        if (user.getRole() == UserRole.ADMIN && request.adminProfile() != null && !request.adminProfile().isBlank()) {
            user.setAdminProfile(normalizeAdminProfile(request.adminProfile()));
        }
        setProfileFields(user, request);
    }

    private void setProfileFields(AdminUser user, AccountUserRequest request) {
        user.setFullName(request.fullName().trim());
        user.setPhone(normalizeBlank(request.phone()));
        user.setAvatarUrl(normalizeBlank(request.avatarUrl()));
    }

    private void changePassword(AdminUser user, AccountPasswordRequest request) {
        ensurePasswordManagedLocally(user);
        PasswordPolicySupport.validateStrongPassword(request.password());
        LocalDateTime changedAt = LocalDateTime.now();
        user.setPasswordHash(passwordEncoder.encode(requirePassword(request.password())));
        user.setPasswordSetAt(changedAt);
        user.setSecurityVersion(nextSecurityVersion(user));
        adminUserRepository.save(user);
        mailNotificationService.sendPasswordChangedNotification(user, changedAt);
    }

    private void ensurePasswordManagedLocally(AdminUser user) {
        if (usesGoogleSignIn(user)) {
            throw new BadRequestException("Google sign-in accounts cannot have a CMS password reset");
        }
    }

    private boolean usesGoogleSignIn(AdminUser user) {
        if (user.getAuthProvider() == AuthProvider.GOOGLE) {
            return true;
        }
        String avatarUrl = user.getAvatarUrl();
        return avatarUrl != null && avatarUrl.contains("googleusercontent.com");
    }

    private Sort defaultSort() {
        return Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by("email"));
    }

    private AdminUser getUser(Long id, UserRole role, String message) {
        AdminUser user = adminUserRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(message));
        if (user.getRole() != role) {
            throw new ResourceNotFoundException(message);
        }
        return user;
    }

    private void ensureEmailAvailable(String email, Long currentId) {
        boolean exists = currentId == null
                ? adminUserRepository.existsByEmailIgnoreCase(email)
                : adminUserRepository.existsByEmailIgnoreCaseAndIdNot(email, currentId);
        if (exists) {
            throw new BadRequestException("Email is already used by another account");
        }
    }

    private void ensureCanRemoveLastSystemAdmin(
            AdminUser user,
            String requestedStatus,
            AdminProfile requestedProfile,
            UserRole requestedRole
    ) {
        boolean currentlyCapable = user.getRole() == UserRole.ADMIN
                && "ACTIVE".equalsIgnoreCase(user.getStatus())
                && isSystemProfile(effectiveProfile(user));
        boolean remainsCapable = requestedRole == UserRole.ADMIN
                && "ACTIVE".equalsIgnoreCase(requestedStatus)
                && isSystemProfile(requestedProfile);
        if (!currentlyCapable || remainsCapable) {
            return;
        }
        List<AdminUser> activeSystemAdmins = adminUserRepository.lockActiveSystemAdmins();
        if (activeSystemAdmins.size() <= 1) {
            throw new BadRequestException("Cannot remove access from the last active SYSTEM/FULL administrator");
        }
    }

    private void ensureNotDeletingSelf(Long targetUserId) {
        Long currentUserId = resolveCurrentUserId();
        if (currentUserId != null && currentUserId.equals(targetUserId)) {
            throw new BadRequestException("Cannot delete your own account while signed in");
        }
    }

    private void ensureNotDeactivatingSelf(AdminUser user, String requestedStatus) {
        if ("ACTIVE".equalsIgnoreCase(requestedStatus)) {
            return;
        }
        Long currentUserId = resolveCurrentUserId();
        if (currentUserId != null && currentUserId.equals(user.getId())) {
            throw new BadRequestException("Cannot deactivate or lock your own account while signed in");
        }
    }

    private Long resolveCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof CustomUserDetails principal)) {
            return null;
        }
        return principal.getUser().getId();
    }

    private AdminProfile normalizeAdminProfile(String profile) {
        if (profile == null || profile.isBlank()) {
            return AdminProfile.CONTENT;
        }
        try {
            return AdminProfile.valueOf(profile.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new BadRequestException("Admin profile is invalid");
        }
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase();
    }

    private String normalizeStatus(String status) {
        String normalized = status == null || status.isBlank() ? "ACTIVE" : status.trim().toUpperCase(Locale.ROOT);
        if ("INACTIVE".equals(normalized)) {
            normalized = "SUSPENDED";
        }
        if (!ALLOWED_STATUSES.contains(normalized)) {
            throw new BadRequestException("Account status is invalid");
        }
        return normalized;
    }

    private String requirePassword(String password) {
        if (password == null || password.isBlank()) {
            throw new BadRequestException("Password is required");
        }
        if (password.length() < 8) {
            throw new BadRequestException("Password must be at least 8 characters");
        }
        return password;
    }

    private String normalizeBlank(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private void applyStatus(AdminUser user, String status, String reason) {
        String normalizedReason = sanitizeReason(reason);
        user.setStatus(status);
        user.setStatusReason(normalizedReason);
        user.setSecurityVersion(nextSecurityVersion(user));
        if ("DEACTIVATED".equals(status)) {
            user.setDeactivatedAt(LocalDateTime.now());
            user.setDeactivatedBy(currentActorEmail());
        } else {
            user.setDeactivatedAt(null);
            user.setDeactivatedBy(null);
        }
    }

    private void verifyVersion(AdminUser user, Long expectedVersion) {
        if (expectedVersion == null) {
            return;
        }
        if (!expectedVersion.equals(user.getVersion())) {
            throw new ConflictException("Account was changed by another administrator. Reload and try again");
        }
    }

    private long nextSecurityVersion(AdminUser user) {
        return (user.getSecurityVersion() == null ? 0L : user.getSecurityVersion()) + 1L;
    }

    private AdminProfile effectiveProfile(AdminUser user) {
        return user.getAdminProfile() == null ? AdminProfile.CONTENT : user.getAdminProfile();
    }

    private boolean isSystemProfile(AdminProfile profile) {
        return profile == AdminProfile.FULL || profile == AdminProfile.SYSTEM;
    }

    private String sanitizeReason(String reason) {
        if (reason == null || reason.isBlank()) {
            throw new BadRequestException("Reason is required");
        }
        String normalized = reason.trim();
        if (normalized.length() > 500) {
            throw new BadRequestException("Reason must be at most 500 characters");
        }
        return normalized;
    }

    private String currentActorEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            return "system";
        }
        return authentication.getName();
    }

    private void recordRoleHistory(
            AdminUser user,
            UserRole fromRole,
            AdminProfile fromProfile,
            UserRole toRole,
            AdminProfile toProfile,
            String reason
    ) {
        AccountRoleHistory history = new AccountRoleHistory();
        history.setUserId(user.getId());
        history.setFromRole(fromRole.name());
        history.setToRole(toRole.name());
        history.setFromAdminProfile(fromProfile == null ? null : fromProfile.name());
        history.setToAdminProfile(toProfile == null ? null : toProfile.name());
        history.setReason(sanitizeReason(reason));
        history.setChangedBy(currentActorEmail());
        accountRoleHistoryRepository.save(history);
    }

    private void transferChatAssignments(AdminUser user, Long transferToAdminId) {
        long assignedCount = chatSessionRepository.countByAssignedAdminId(user.getId());
        if (assignedCount == 0) {
            return;
        }
        if (transferToAdminId == null) {
            throw new BadRequestException("Select an active administrator to receive assigned live chats");
        }
        if (user.getId().equals(transferToAdminId)) {
            throw new BadRequestException("Chat assignments must be transferred to another administrator");
        }
        AdminUser recipient = getUser(transferToAdminId, UserRole.ADMIN, "Transfer administrator not found");
        if (!"ACTIVE".equalsIgnoreCase(recipient.getStatus())) {
            throw new BadRequestException("Transfer administrator must be active");
        }
        chatSessionRepository.transferAssignments(user.getId(), recipient.getId());
    }
}
