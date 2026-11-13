package com.practika.ms_content.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.MaterialService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@RequiredArgsConstructor
public class MaterialController {
    private final MaterialService service;

    @GetMapping("/preguntas/{id}/materiales")
    public List<MaterialResponse> listarMaterialesPregunta(@PathVariable Integer id, Authentication authentication) {
        return service.listarDePregunta(id, authentication);
    }

    @PostMapping("/preguntas/{id}/materiales")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse crearMaterialPregunta(@PathVariable Integer id, @Valid @RequestBody MaterialRequest dto) {
        return service.crearEnPregunta(id, dto);
    }

    @GetMapping("/actividades/{id}/materiales")
    public List<MaterialResponse> listarMateriales(@PathVariable Integer id, Authentication authentication) {
        return service.listarDeActividad(id, authentication);
    }

    @PostMapping("/actividades/{id}/materiales")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse crearMaterial(@PathVariable Integer id, @Valid @RequestBody MaterialRequest dto) {
        return service.crearEnActividad(id, dto);
    }

    @PutMapping("/materiales/{id}")
    @PreAuthorize("hasRole('UTP')")
    public MaterialResponse actualizarMaterial(@PathVariable Integer id, @Valid @RequestBody MaterialRequest dto) {
        return service.actualizar(id, dto);
    }

    @PatchMapping("/materiales/{id}/estado")
    @PreAuthorize("hasRole('UTP')")
    public MaterialResponse cambiarEstadoMaterial(@PathVariable Integer id, @RequestParam boolean activo) {
        return service.cambiarEstado(id, activo);
    }

    @DeleteMapping("/materiales/{id}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarMaterial(@PathVariable Integer id) {
        service.eliminar(id);
    }
}
