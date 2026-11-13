package com.practika.ms_content.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.UnidadService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class AsignacionController {
    private final UnidadService service;

    @PostMapping("/asignaciones")
    @PreAuthorize("hasRole('PROFESOR')")
    @ResponseStatus(HttpStatus.CREATED)
    public UnidadCursoResponse asignar(@Valid @RequestBody UnidadCursoRequest dto, Authentication authentication) {
        return service.asignar(dto, authentication);
    }

    @GetMapping("/cursos/{idCurso}/unidades/disponibles")
    @PreAuthorize("hasAnyRole('UTP','PROFESOR')")
    public List<UnidadResponse> unidadesDisponibles(@PathVariable Integer idCurso, Authentication authentication) {
        return service.unidadesDisponibles(idCurso, authentication);
    }

    @GetMapping("/unidades/{idUnidad}/cursos/{idCurso}/asignada")
    public boolean estaAsignada(@PathVariable Integer idUnidad, @PathVariable Integer idCurso) {
        return service.estaAsignada(idUnidad, idCurso);
    }

    @GetMapping("/unidades/{idUnidad}/secciones/{idSeccion}/asignada")
    public boolean estaAsignadaASeccion(@PathVariable Integer idUnidad, @PathVariable Integer idSeccion,
            Authentication authentication) {
        return service.estaAsignadaASeccion(idUnidad, idSeccion, authentication);
    }
}
