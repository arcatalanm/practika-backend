package com.practika.ms_auth.security;

import java.io.IOException;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.web.filter.OncePerRequestFilter;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public final class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtValidator validator;
    private final JwtIdentityResolver identities;

    public JwtAuthenticationFilter(JwtValidator validator, JwtIdentityResolver identities) {
        this.validator = validator;
        this.identities = identities;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain chain) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header != null && header.startsWith("Bearer ")) {
            try {
                var claims = validator.claims(header.substring(7).trim());
                Authentication authentication = identities.resolve(claims)
                        .orElseThrow(() -> new JwtException("La cuenta no está disponible"));
                if (authentication instanceof AbstractAuthenticationToken token) {
                    token.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                }
                if (SecurityContextHolder.getContext().getAuthentication() == null) {
                    var context = SecurityContextHolder.createEmptyContext();
                    context.setAuthentication(authentication);
                    SecurityContextHolder.setContext(context);
                }
            } catch (JwtException | IllegalArgumentException ex) {
                SecurityContextHolder.clearContext();
                SecurityErrorWriter.write(response, request, 401, "Unauthorized",
                        "Inicia sesión para continuar.");
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
