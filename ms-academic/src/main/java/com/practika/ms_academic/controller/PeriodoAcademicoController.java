package com.practika.ms_academic.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_academic.dto.PeriodoAcademicoRequest;
import com.practika.ms_academic.dto.PeriodoAcademicoResponse;
import com.practika.ms_academic.service.PeriodoAcademicoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping({"/api/v1/academic/catalogos/periodos-academicos", "/api/v1/content/catalogos/periodos-academicos"}) @RequiredArgsConstructor
public class PeriodoAcademicoController {
    private final PeriodoAcademicoService service;

    @GetMapping
    public List<PeriodoAcademicoResponse> listar() {
        return service.listar();
    }

    @PostMapping @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public PeriodoAcademicoResponse crear(@Valid @RequestBody PeriodoAcademicoRequest dto) {
        return service.crear(dto);
    }

    @PatchMapping("/{id}/estado") @PreAuthorize("hasRole('UTP')")
    public PeriodoAcademicoResponse estado(@PathVariable Integer id, @RequestParam boolean activo) {
        return service.cambiarEstado(id, activo);
    }
}
