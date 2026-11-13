package com.practika.ms_grading.controller;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_grading.dto.*;
import com.practika.ms_grading.service.EntregaService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/grading/entregas") @RequiredArgsConstructor
@SecurityRequirement(name="bearerAuth")
public class EntregaController {
    private final EntregaService service;

    @GetMapping @PreAuthorize("hasRole('PROFESOR')")
    public java.util.List<EntregaResponse> listar(Authentication auth,
            @RequestParam(required=false) Integer idCursoPortal) { return service.listar(auth, idCursoPortal); }

    @GetMapping("/mias")
    public java.util.List<EntregaResponse> propias(Authentication auth) { return service.propias(auth); }

    public record ContextoRequest(@jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Positive Integer idEvaluacionAsignada) {}
    public record HistoricasRequest(@jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Positive Integer runEstudiante,
            @jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Positive Integer idEvaluacionAsignada,
            @jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Min(1) Integer numeroIntento) {}
    @PutMapping("/{id}/contexto") @PreAuthorize("hasRole('PROFESOR')")
    public EntregaResponse contextualizar(@PathVariable Integer id,@Valid @RequestBody ContextoRequest request,Authentication auth) {
        return service.vincularHistorica(id,request.idEvaluacionAsignada(),auth);
    }
    @PostMapping("/historicas") @PreAuthorize("hasRole('PROFESOR')")
    public EntregaResponse importar(@Valid @RequestBody HistoricasRequest request,Authentication auth) {
        return service.importarHistoricas(request.runEstudiante(),request.idEvaluacionAsignada(),request.numeroIntento(),auth);
    }

    @PostMapping("/{id}/reintento") @PreAuthorize("hasRole('PROFESOR')")
    public EntregaResponse permitirReintento(@PathVariable Integer id, Authentication auth) {
        return service.permitirReintento(id, auth);
    }

    @PutMapping("/{id}/comentario") @PreAuthorize("hasRole('PROFESOR')")
    public EntregaResponse comentar(@PathVariable Integer id, @Valid @RequestBody ComentarioEntregaRequest request, Authentication auth) {
        return service.comentar(id, request.comentario(), auth);
    }

    @GetMapping("/estado")
    public EstadoEntregaResponse estado(@RequestParam Integer runEstudiante,
            @RequestParam Integer idEvaluacionAsignada,
            Authentication auth) {
        return service.estado(runEstudiante,idEvaluacionAsignada,auth);
    }

    @PostMapping @ResponseStatus(HttpStatus.CREATED) @PreAuthorize("hasRole('ESTUDIANTE')")
    public EntregaResponse crear(@Valid @RequestBody EntregaRequest request, Authentication auth) {
        return service.crear(request, auth);
    }
}
