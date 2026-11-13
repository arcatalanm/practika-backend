package com.practika.ms_auth.security;

import java.util.Optional;
import org.springframework.security.core.Authentication;
import io.jsonwebtoken.Claims;

/** Allows identity services to check the current account before accepting a JWT. */
@FunctionalInterface
public interface JwtIdentityResolver {
    Optional<Authentication> resolve(Claims claims);
}
