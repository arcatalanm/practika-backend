package com.practika.ms_content.controller;

import java.util.List;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.model.TipoEvaluacion;
import com.practika.ms_content.service.*;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class EvaluacionAutoriaController {
    private final EvaluacionService evaluaciones;
    private final PreguntaService preguntas;

    @GetMapping("/autoria/evaluaciones")
    public List<EvaluacionResponse> listar(@RequestParam(required = false) @Positive Integer idUnidad,
            Authentication auth) {
        return evaluaciones.listar(idUnidad, auth).stream().map(EvaluacionResponse::from).toList();
    }

    @GetMapping("/unidades/{idUnidad}/evaluaciones")
    public List<EvaluacionResponse> listarEnUnidad(@PathVariable @Positive Integer idUnidad, Authentication auth) {
        return evaluaciones.listar(idUnidad, auth).stream().map(EvaluacionResponse::from).toList();
    }

    @GetMapping("/autoria/evaluaciones/{tipo}/{id}")
    public EvaluacionDetalleResponse obtener(@PathVariable TipoEvaluacion tipo,
            @PathVariable @Positive Integer id, Authentication auth) {
        var ref = new EvaluacionRef(tipo, id);
        return new EvaluacionDetalleResponse(EvaluacionResponse.from(evaluaciones.obtener(ref, auth)),
                preguntas.listarDeEvaluacion(ref, auth));
    }

    @PostMapping("/autoria/evaluaciones")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public EvaluacionResponse crear(@Valid @RequestBody EvaluacionRequest dto) {
        return EvaluacionResponse.from(evaluaciones.crear(dto));
    }

    @PostMapping("/unidades/{idUnidad}/evaluaciones")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public EvaluacionResponse crearEnUnidad(@PathVariable @Positive Integer idUnidad,
            @Valid @RequestBody EvaluacionEnUnidadRequest dto) {
        return EvaluacionResponse.from(evaluaciones.crear(dto.enUnidad(idUnidad)));
    }

    @PutMapping("/autoria/evaluaciones/{tipo}/{id}")
    @PreAuthorize("hasRole('UTP')")
    public EvaluacionResponse actualizar(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id,
            @Valid @RequestBody EvaluacionEdicionRequest dto) {
        return EvaluacionResponse.from(evaluaciones.actualizarContenido(new EvaluacionRef(tipo, id), dto));
    }

    @PatchMapping("/autoria/evaluaciones/{tipo}/{id}/estado")
    @PreAuthorize("hasRole('UTP')")
    public EvaluacionResponse estado(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id,
            @RequestParam boolean activo) {
        return EvaluacionResponse.from(evaluaciones.cambiarEstado(new EvaluacionRef(tipo, id), activo));
    }

    @DeleteMapping("/autoria/evaluaciones/{tipo}/{id}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id) {
        evaluaciones.eliminar(new EvaluacionRef(tipo, id));
    }

    @GetMapping("/autoria/evaluaciones/{tipo}/{id}/preguntas")
    public List<PreguntaResponse> listarPreguntas(@PathVariable TipoEvaluacion tipo,
            @PathVariable @Positive Integer id, Authentication auth) {
        return preguntas.listarDeEvaluacion(new EvaluacionRef(tipo, id), auth);
    }

    @PostMapping("/autoria/evaluaciones/{tipo}/{id}/preguntas")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public PreguntaResponse crearPregunta(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id,
            @Valid @RequestBody PreguntaEnEvaluacionRequest dto) {
        return preguntas.crearEnEvaluacion(new EvaluacionRef(tipo, id), dto);
    }

    @PutMapping("/autoria/evaluaciones/{tipo}/{id}/preguntas/{idPregunta}")
    @PreAuthorize("hasRole('UTP')")
    public PreguntaResponse actualizarPregunta(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id,
            @PathVariable @Positive Integer idPregunta, @Valid @RequestBody PreguntaEnEvaluacionRequest dto) {
        return preguntas.actualizarEnEvaluacion(new EvaluacionRef(tipo, id), idPregunta, dto);
    }

    @DeleteMapping("/autoria/evaluaciones/{tipo}/{id}/preguntas/{idPregunta}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarPregunta(@PathVariable TipoEvaluacion tipo, @PathVariable @Positive Integer id,
            @PathVariable @Positive Integer idPregunta) {
        preguntas.eliminarEnEvaluacion(new EvaluacionRef(tipo, id), idPregunta);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> error(ResponseStatusException ex) {
        return ResponseEntity.status(ex.getStatusCode()).body(Map.of("message",
                ex.getReason() == null ? "No se pudo procesar la evaluación" : ex.getReason()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> contenidoRelacionado(DataIntegrityViolationException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message",
                "La evaluación tiene contenido relacionado que debe conservarse"));
    }
}
