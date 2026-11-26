package com.practika.ms_auth.security;

import java.util.Optional;
import org.springframework.security.core.Authentication;
import io.jsonwebtoken.Claims;

@FunctionalInterface
public interface JwtIdentityResolver {
    Optional<Authentication> resolve(Claims claims);
}
