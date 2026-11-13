package com.practika.ms_academic.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_academic.dto.CursoPortalRequest;
import com.practika.ms_academic.dto.CursoPortalResponse;
import com.practika.ms_academic.service.CursoPortalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping({"/api/v1/academic", "/api/v1/content"}) @RequiredArgsConstructor
public class CursoPortalController {
    private final CursoPortalService service;
    @GetMapping({"/cursos-portal", "/secciones/asignaturas"})
    public List<CursoPortalResponse> listar(Authentication auth) { return service.listar(auth); }

    @GetMapping({"/cursos-portal/{id}", "/secciones/asignaturas/{id}"})
    public CursoPortalResponse obtener(@PathVariable Integer id, Authentication auth) {
        service.validarAcceso(id, auth);
        return service.obtener(id);
    }

    @GetMapping({"/cursos-portal/{id}/contexto", "/secciones/asignaturas/{id}/contexto"})
    public com.practika.ms_academic.dto.CursoContextoResponse contexto(
            @PathVariable Integer id, Authentication auth) {
        return service.contexto(id, auth);
    }

    @GetMapping({"/cursos-portal/{id}/participantes", "/secciones/asignaturas/{id}/participantes"})
    public List<com.practika.ms_academic.client.IdentityClient.UsuarioRef> participantes(
            @PathVariable Integer id, Authentication auth) {
        return service.participantes(id, auth);
    }

    @GetMapping({"/cursos-portal/{id}/lista", "/secciones/asignaturas/{id}/lista"})
    public List<com.practika.ms_academic.client.IdentityClient.PersonaPublicaRef> lista(
            @PathVariable Integer id, Authentication auth) {
        return service.lista(id, auth);
    }

    @GetMapping("/secciones/asignaturas/{id}/vinculos")
    public List<Integer> vinculos(@PathVariable Integer id, Authentication auth) { return service.vinculos(id,auth); }

    @PostMapping("/cursos-portal") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public CursoPortalResponse crear(@Valid @RequestBody CursoPortalRequest dto) { return service.crear(dto); }

    @PutMapping("/cursos-portal/{id}") @PreAuthorize("hasRole('UTP')")
    public CursoPortalResponse actualizar(@PathVariable Integer id, @Valid @RequestBody CursoPortalRequest dto) {
        return service.actualizar(id, dto);
    }

    @PatchMapping("/cursos-portal/{id}/estado") @PreAuthorize("hasRole('UTP')")
    public CursoPortalResponse estado(@PathVariable Integer id, @RequestParam boolean activo) {
        return service.estado(id, activo);
    }

    @PostMapping("/cursos-portal/{id}/docentes/{run}") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void asignarDocente(@PathVariable Integer id, @PathVariable Integer run) { service.asignarDocente(id, run); }

    @DeleteMapping("/cursos-portal/{id}/docentes/{run}") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void quitarDocente(@PathVariable Integer id, @PathVariable Integer run) { service.quitarDocente(id, run); }
}
