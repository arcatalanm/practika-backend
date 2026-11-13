package com.practika.ms_academic.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import com.practika.ms_academic.dto.AsignaturaRequest;
import com.practika.ms_academic.dto.ObjetivoRequest;
import com.practika.ms_academic.dto.AsignaturaResponse;
import com.practika.ms_academic.dto.ObjetivoResponse;
import com.practika.ms_academic.service.AcademicService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/academic")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class AcademicController {
    private final AcademicService service;

    @GetMapping("/asignaturas")
    public List<AsignaturaResponse> listarAsignaturas() {
        return service.listarAsignaturas();
    }

    @GetMapping("/asignaturas/{id}")
    public AsignaturaResponse obtenerAsignatura(@PathVariable Integer id) {
        return service.obtenerAsignatura(id);
    }

    @PostMapping("/asignaturas")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public AsignaturaResponse crearAsignatura(@Valid @RequestBody AsignaturaRequest dto) {
        return service.crearAsignatura(dto);
    }

    @PutMapping("/asignaturas/{id}")
    @PreAuthorize("hasRole('UTP')")
    public AsignaturaResponse actualizarAsignatura(@PathVariable Integer id, @Valid @RequestBody AsignaturaRequest dto) {
        return service.actualizarAsignatura(id, dto);
    }

    @PatchMapping("/asignaturas/{id}/estado")
    @PreAuthorize("hasRole('UTP')")
    public AsignaturaResponse cambiarEstadoAsignatura(@PathVariable Integer id, @RequestParam boolean activo) {
        return service.cambiarEstadoAsignatura(id, activo);
    }

    @GetMapping("/objetivos")
    public List<ObjetivoResponse> listarObjetivos(@RequestParam(required = false) Integer idAsignatura) {
        return service.listarObjetivos(idAsignatura);
    }

    @GetMapping("/objetivos/{id}")
    public ObjetivoResponse obtenerObjetivo(@PathVariable Integer id) {
        return service.obtenerObjetivo(id);
    }

    @GetMapping("/asignaturas/{id}/objetivos")
    public List<ObjetivoResponse> objetivosDeAsignatura(@PathVariable Integer id) {
        return service.objetivosDeAsignatura(id);
    }

    @PostMapping("/objetivos")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public ObjetivoResponse crearObjetivo(@Valid @RequestBody ObjetivoRequest dto) {
        return service.crearObjetivo(dto);
    }

    @PutMapping("/objetivos/{id}")
    @PreAuthorize("hasRole('UTP')")
    public ObjetivoResponse actualizarObjetivo(@PathVariable Integer id, @Valid @RequestBody ObjetivoRequest dto) {
        return service.actualizarObjetivo(id, dto);
    }

    @DeleteMapping("/objetivos/{id}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarObjetivo(@PathVariable Integer id) {
        service.eliminarObjetivo(id);
    }
}
