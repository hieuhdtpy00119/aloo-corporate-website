package com.aloo.cms.security;

import com.aloo.cms.entity.UserRole;
import com.aloo.cms.repository.AdminUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminUserDetailsService implements UserDetailsService {

    private final AdminUserRepository adminUserRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return adminUserRepository.findByEmailIgnoreCaseAndRole(username, UserRole.ADMIN)
                .map(CustomUserDetails::new)
                .orElseThrow(() -> new UsernameNotFoundException("Admin user not found"));
    }

    public UserDetails loadAnyUserByUsername(String username) throws UsernameNotFoundException {
        return adminUserRepository.findByEmailIgnoreCase(username)
                .map(CustomUserDetails::new)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }
}

