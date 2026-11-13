package com.practika.ms_content.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.EvaluacionService;
import com.practika.ms_content.service.EvaluacionRef;
import com.practika.ms_content.model.TipoEvaluacion;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@RequiredArgsConstructor
public class PruebaController {
    private final EvaluacionService service;

    @GetMapping("/pruebas")
    public List<PruebaResponse> listarPruebas() {
        return service.listarPorTipo(TipoEvaluacion.PRUEBA).stream().map(PruebaResponse::from).toList();
    }

    @GetMapping("/pruebas/{id}")
    public PruebaResponse obtenerPrueba(@PathVariable Integer id, Authentication authentication) {
        return PruebaResponse.from(service.obtener(new EvaluacionRef(TipoEvaluacion.PRUEBA, id), authentication));
    }

    @PostMapping("/pruebas")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public PruebaResponse crearPrueba(@Valid @RequestBody PruebaRequest dto) {
        return PruebaResponse.from(service.crear(EvaluacionRequest.dePrueba(dto)));
    }

    @PutMapping("/pruebas/{id}")
    @PreAuthorize("hasRole('UTP')")
    public PruebaResponse actualizarPrueba(@PathVariable Integer id, @Valid @RequestBody PruebaRequest dto) {
        return PruebaResponse.from(service.actualizar(new EvaluacionRef(TipoEvaluacion.PRUEBA, id), EvaluacionRequest.dePrueba(dto)));
    }

    @PatchMapping("/pruebas/{id}/estado")
    @PreAuthorize("hasRole('UTP')")
    public PruebaResponse estadoPrueba(@PathVariable Integer id, @RequestParam boolean activo) {
        return PruebaResponse.from(service.cambiarEstado(new EvaluacionRef(TipoEvaluacion.PRUEBA, id), activo));
    }
}
