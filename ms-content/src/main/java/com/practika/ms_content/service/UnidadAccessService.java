package com.practika.ms_content.service;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.client.IdentityClient;
import com.practika.ms_content.repository.UnidadCursoRepository;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UnidadAccessService {
    private final IdentityClient identity;
    private final UnidadCursoRepository asignaciones;
    private final CursoPortalService cursos;

    public void validarAcceso(Integer idUnidad, Authentication authentication) {
        if (tieneRol(authentication, "UTP", "PROFESOR")) return;
        IdentityClient.UsuarioRef usuario;
        try {
            usuario = identity.obtenerUsuarioActual();
        } catch (FeignException ex) {
            if (ex.status() == 401) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Inicia sesión para continuar.");
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "No se pudo consultar la cuenta en ms-auth", ex);
        }
        if (!tieneAcceso(usuario, idUnidad)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "La unidad no está asignada a tu curso");
        }
    }

    private boolean tieneAcceso(IdentityClient.UsuarioRef usuario, Integer idUnidad) {
        return cursos.cursosActuales(usuario).stream()
                .anyMatch(id -> asignaciones.existsByIdCursoAndIdUnidad(id, idUnidad));
    }

    public boolean tieneRol(Authentication authentication, String... roles) {
        return authentication.getAuthorities().stream().anyMatch(a ->
                java.util.Arrays.stream(roles).anyMatch(r -> a.getAuthority().equals("ROLE_" + r)));
    }
}
