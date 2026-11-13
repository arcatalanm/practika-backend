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
public class ActividadController {
    private final EvaluacionService service;

    @GetMapping("/actividades")
    public List<ActividadResponse> listarActividades() {
        return service.listarPorTipo(TipoEvaluacion.ACTIVIDAD).stream().map(ActividadResponse::from).toList();
    }

    @GetMapping("/actividades/{id}")
    public ActividadResponse obtenerActividad(@PathVariable Integer id, Authentication authentication) {
        return ActividadResponse.from(service.obtener(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id), authentication));
    }

    @PostMapping("/actividades")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public ActividadResponse crearActividad(@Valid @RequestBody ActividadRequest dto) {
        return ActividadResponse.from(service.crear(EvaluacionRequest.deActividad(dto)));
    }

    @PutMapping("/actividades/{id}")
    @PreAuthorize("hasRole('UTP')")
    public ActividadResponse actualizarActividad(@PathVariable Integer id, @Valid @RequestBody ActividadRequest dto) {
        return ActividadResponse.from(service.actualizar(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id), EvaluacionRequest.deActividad(dto)));
    }

    @PatchMapping("/actividades/{id}/estado")
    @PreAuthorize("hasRole('UTP')")
    public ActividadResponse estadoActividad(@PathVariable Integer id, @RequestParam boolean activo) {
        return ActividadResponse.from(service.cambiarEstado(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id), activo));
    }
}
