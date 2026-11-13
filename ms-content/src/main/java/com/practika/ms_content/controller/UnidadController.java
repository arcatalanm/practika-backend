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
public class UnidadController {
    private final UnidadService service;

    @PostMapping("/unidades")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public UnidadResponse crear(@Valid @RequestBody UnidadRequest dto) {
        return service.crear(dto);
    }

    @PostMapping("/cursos/{idCurso}/unidades")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public UnidadResponse crearEnCurso(@PathVariable Integer idCurso, @Valid @RequestBody UnidadEnCursoRequest dto,
            Authentication authentication) {
        return service.crearEnCurso(idCurso, dto, authentication);
    }

    @PutMapping("/unidades/{id}")
    @PreAuthorize("hasRole('UTP')")
    public UnidadResponse actualizar(@PathVariable Integer id, @Valid @RequestBody UnidadRequest dto) {
        return service.actualizar(id, dto);
    }

    @GetMapping("/unidades")
    public List<UnidadDetalleResponse> listar(@RequestParam(required = false) Integer idAsignatura,
            Authentication authentication) {
        return service.listar(idAsignatura, authentication);
    }

    @GetMapping("/unidades/{id}")
    public UnidadDetalleResponse detalle(@PathVariable Integer id,
            @RequestParam(required = false) Integer idCursoPortal, Authentication authentication) {
        return service.detalle(id, idCursoPortal, authentication);
    }

    @GetMapping({"/cursos/{idCurso}/unidades", "/secciones/asignaturas/{idCurso}/unidades"})
    public List<UnidadDetalleResponse> listarDeCurso(@PathVariable Integer idCurso, Authentication authentication) {
        return service.listarDeCurso(idCurso, authentication);
    }
}
