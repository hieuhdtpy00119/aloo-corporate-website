package com.aloo.cms.security;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.service.AdminPermissionService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    private final AdminPermissionService adminPermissionService;

    public JwtService(AdminPermissionService adminPermissionService) {
        this.adminPermissionService = adminPermissionService;
    }

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration-ms}")
    private long jwtExpirationMs;

    public String generateToken(AdminUser user) {
        return generateToken(user.getEmail(), user.getRole().name(), adminPermissionService.resolveScopes(user));
    }

    public String generateToken(String email, String role) {
        return generateToken(email, role, java.util.List.of());
    }

    public String generateToken(String email, String role, java.util.List<String> scopes) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .claim("scopes", scopes)
                .issuedAt(now)
                .expiration(expiration)
                .signWith(signingKey())
                .compact();
    }

    public String extractEmail(String token) {
        return claims(token).getSubject();
    }

    public boolean isTokenValid(String token, UserDetails userDetails) {
        try {
            String email = extractEmail(token);
            return email.equalsIgnoreCase(userDetails.getUsername()) && !isExpired(token);
        } catch (JwtException | IllegalArgumentException ex) {
            return false;
        }
    }

    public boolean isTokenValidForEmail(String token, String expectedEmail) {
        try {
            String email = extractEmail(token);
            return email.equalsIgnoreCase(expectedEmail) && !isExpired(token);
        } catch (JwtException | IllegalArgumentException ex) {
            return false;
        }
    }

    private boolean isExpired(String token) {
        return claims(token).getExpiration().before(new Date());
    }

    private Claims claims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private SecretKey signingKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }
}
