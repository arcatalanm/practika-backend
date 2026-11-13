package com.practika.ms_grading.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "identity-service", url = "${IDENTITY_SERVICE_URL:http://localhost:8081}")
public interface IdentityClient {
    @GetMapping("/api/v1/auth/me")
    UsuarioRef obtenerUsuarioActual();

    @GetMapping("/api/v1/auth/usuarios/{run}")
    UsuarioRef obtenerUsuario(@PathVariable("run") Integer run);

    @GetMapping("/api/v1/auth/secciones/{id}/matriculas/{run}")
    Boolean tieneMatricula(@PathVariable("id") Integer id,@PathVariable("run") Integer run,
            @org.springframework.web.bind.annotation.RequestParam("soloActivas") boolean soloActivas);

    record SeccionRef(Integer id, Boolean activo) {}
    record UsuarioRef(Integer run, String rol, SeccionRef seccion, Boolean activo) {}
}
