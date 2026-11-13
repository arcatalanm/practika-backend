package com.practika.ms_academic.security;

import java.io.IOException;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.filter.OncePerRequestFilter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public final class RemoteAuthenticationFilter extends OncePerRequestFilter {
    private final AuthIdentityClient identities;

    public RemoteAuthenticationFilter(AuthIdentityClient identities) {
        this.identities = identities;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain chain) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (header != null && header.startsWith("Bearer ")) {
            AuthIdentityClient.Identity identity;
            try {
                identity = identities.resolve(header);
                if (identity == null || identity.run() == null || identity.run() <= 0
                        || identity.rol() == null || identity.rol().isBlank()) {
                    unavailable(request, response);
                    return;
                }
            } catch (RestClientResponseException ex) {
                SecurityContextHolder.clearContext();
                if (ex.getStatusCode().value() == 401) {
                    SecurityErrorWriter.write(response, request, 401, "Unauthorized", "Inicia sesión para continuar.");
                } else {
                    unavailable(request, response);
                }
                return;
            } catch (RestClientException ex) {
                unavailable(request, response);
                return;
            }
            var authentication = new UsernamePasswordAuthenticationToken(identity.run(), null,
                    List.of(new SimpleGrantedAuthority("ROLE_" + identity.rol())));
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            var context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(authentication);
            SecurityContextHolder.setContext(context);
        }
        chain.doFilter(request, response);
    }

    private void unavailable(HttpServletRequest request, HttpServletResponse response) throws IOException {
        SecurityContextHolder.clearContext();
        SecurityErrorWriter.write(response, request, 503, "Service Unavailable",
                "No se pudo verificar la sesión. Intenta nuevamente.");
    }
}
