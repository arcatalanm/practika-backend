package com.practika.ms_auth.security;

import java.nio.charset.StandardCharsets;
import javax.crypto.SecretKey;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

public final class JwtValidator {
    private final SecretKey key;
    private final String issuer;

    public JwtValidator(String secret, String issuer) {
        byte[] bytes = secret == null ? new byte[0] : secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("JWT_SECRET debe tener al menos 32 bytes");
        }
        if (issuer == null || issuer.isBlank()) {
            throw new IllegalStateException("JWT_ISSUER no puede estar vacío");
        }
        this.key = Keys.hmacShaKeyFor(bytes);
        this.issuer = issuer;
    }

    public Claims claims(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(key)
                .requireIssuer(issuer)
                .build()
                .parseSignedClaims(token)
                .getPayload();
        String role = claims.get("rol", String.class);
        if (claims.getSubject() == null || claims.getSubject().isBlank()
                || role == null || role.isBlank()) {
            throw new JwtException("Token sin identidad o rol");
        }
        return claims;
    }
}
