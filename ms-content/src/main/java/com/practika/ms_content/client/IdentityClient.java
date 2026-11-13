package com.practika.ms_content.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "identity-service", url = "${IDENTITY_SERVICE_URL:http://localhost:8081}")
public interface IdentityClient {
    @GetMapping("/api/v1/auth/me")
    UsuarioRef obtenerUsuarioActual();

    @GetMapping("/api/v1/auth/secciones/{id}")
    SeccionRef obtenerSeccion(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/auth/usuarios/{run}")
    UsuarioRef obtenerUsuario(@PathVariable("run") Integer run);

    @GetMapping("/api/v1/auth/secciones/{id}/participantes?incluirHistoricos=true")
    java.util.List<UsuarioRef> obtenerParticipantes(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/auth/usuarios/docentes/{run}/publico")
    PersonaPublicaRef obtenerDocentePublico(@PathVariable("run") Integer run);

    @GetMapping("/api/v1/auth/usuarios/{run}/matriculas")
    java.util.List<MatriculaRef> obtenerMatriculas(@PathVariable("run") Integer run);

    @GetMapping("/api/v1/auth/secciones/{id}/matriculas/{run}")
    Boolean tieneMatricula(@PathVariable("id") Integer id,@PathVariable("run") Integer run,
            @org.springframework.web.bind.annotation.RequestParam("soloActivas") boolean soloActivas);

    @GetMapping("/api/v1/auth/secciones/{id}/participantes")
    java.util.List<PersonaPublicaRef> obtenerParticipantesActuales(@PathVariable("id") Integer id);

    record MatriculaRef(Integer id,SeccionRef seccion,Boolean activa) {}

    record SeccionRef(Integer id, String nivelEducativo, Boolean activo) {}
    record UsuarioRef(Integer run, Character dv, String nombreCompleto, String rol, SeccionRef seccion, Boolean activo) {}
    record PersonaPublicaRef(Integer run, String nombreCompleto, String rol, String imgPerfil) {}
}
