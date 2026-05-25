package com.aloo.cms.service;

import com.aloo.cms.dto.AccountPasswordRequest;
import com.aloo.cms.dto.AccountStatusRequest;
import com.aloo.cms.dto.AccountUserRequest;
import com.aloo.cms.dto.AccountUserResponse;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.repository.AdminUserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AccountManagementService {

    private static final List<String> ALLOWED_STATUSES = List.of("ACTIVE", "INACTIVE", "LOCKED");

    private final AdminUserRepository adminUserRepository;
    private final PasswordEncoder passwordEncoder;

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
        return createUser(request, UserRole.ADMIN);
    }

    @Transactional
    public AccountUserResponse updateAdminUser(Long id, AccountUserRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        updateCommonFields(user, request);
        String status = normalizeStatus(request.status());
        ensureCanDeactivateLastAdmin(user, status);
        user.setStatus(status);
        return toResponse(adminUserRepository.save(user));
    }

    @Transactional
    public AccountUserResponse updateAdminStatus(Long id, AccountStatusRequest request) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        String status = normalizeStatus(request.status());
        ensureCanDeactivateLastAdmin(user, status);
        user.setStatus(status);
        return toResponse(adminUserRepository.save(user));
    }

    @Transactional
    public void changeAdminPassword(Long id, AccountPasswordRequest request) {
        changePassword(getUser(id, UserRole.ADMIN, "Admin account not found"), request);
    }

    @Transactional
    public void deleteAdminUser(Long id) {
        AdminUser user = getUser(id, UserRole.ADMIN, "Admin account not found");
        ensureCanDeactivateLastAdmin(user, "DELETED");
        adminUserRepository.delete(user);
    }

    @Transactional
    public AccountUserResponse createCustomerUser(AccountUserRequest request) {
        return createUser(request, UserRole.USER);
    }

    @Transactional
    public AccountUserResponse updateCustomerUser(Long id, AccountUserRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        updateCommonFields(user, request);
        user.setStatus(normalizeStatus(request.status()));
        return toResponse(adminUserRepository.save(user));
    }

    @Transactional
    public AccountUserResponse updateCustomerStatus(Long id, AccountStatusRequest request) {
        AdminUser user = getUser(id, UserRole.USER, "Customer account not found");
        user.setStatus(normalizeStatus(request.status()));
        return toResponse(adminUserRepository.save(user));
    }

    @Transactional
    public void changeCustomerPassword(Long id, AccountPasswordRequest request) {
        changePassword(getUser(id, UserRole.USER, "Customer account not found"), request);
    }

    @Transactional
    public void deleteCustomerUser(Long id) {
        adminUserRepository.delete(getUser(id, UserRole.USER, "Customer account not found"));
    }

    private List<AccountUserResponse> findByRole(UserRole role) {
        return adminUserRepository.findAllByRole(role, defaultSort()).stream()
                .map(this::toResponse)
                .toList();
    }

    private AccountUserResponse createUser(AccountUserRequest request, UserRole role) {
        String email = normalizeEmail(request.email());
        ensureEmailAvailable(email, null);
        String password = requirePassword(request.password());

        AdminUser user = new AdminUser();
        user.setRole(role);
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setStatus(normalizeStatus(request.status()));
        setProfileFields(user, request);
        return toResponse(adminUserRepository.save(user));
    }

    private void updateCommonFields(AdminUser user, AccountUserRequest request) {
        String email = normalizeEmail(request.email());
        ensureEmailAvailable(email, user.getId());
        user.setEmail(email);
        setProfileFields(user, request);
    }

    private void setProfileFields(AdminUser user, AccountUserRequest request) {
        user.setFullName(request.fullName().trim());
        user.setPhone(normalizeBlank(request.phone()));
        user.setAvatarUrl(normalizeBlank(request.avatarUrl()));
    }

    private void changePassword(AdminUser user, AccountPasswordRequest request) {
        user.setPasswordHash(passwordEncoder.encode(requirePassword(request.password())));
        adminUserRepository.save(user);
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

    private void ensureCanDeactivateLastAdmin(AdminUser user, String requestedStatus) {
        if ("ACTIVE".equalsIgnoreCase(requestedStatus)) {
            return;
        }
        if ("ACTIVE".equalsIgnoreCase(user.getStatus())
                && adminUserRepository.countByRoleAndStatusIgnoreCase(UserRole.ADMIN, "ACTIVE") <= 1) {
            throw new BadRequestException("Cannot deactivate or delete the last active admin account");
        }
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase();
    }

    private String normalizeStatus(String status) {
        String normalized = status == null || status.isBlank() ? "ACTIVE" : status.trim().toUpperCase();
        if (!ALLOWED_STATUSES.contains(normalized)) {
            throw new BadRequestException("Account status is invalid");
        }
        return normalized;
    }

    private String requirePassword(String password) {
        if (password == null || password.isBlank()) {
            throw new BadRequestException("Password is required");
        }
        return password;
    }

    private String normalizeBlank(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private AccountUserResponse toResponse(AdminUser user) {
        return new AccountUserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getRole().name(),
                user.getStatus(),
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
