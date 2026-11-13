package com.practika.ms_content.controller;

import java.util.List;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content/autoria/evaluaciones/{id}")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@RequiredArgsConstructor
public class EvaluacionCanonicalController {
    private final EvaluacionService evaluaciones;
    private final PreguntaService preguntas;
    private final MaterialService materiales;

    @GetMapping
    public EvaluacionDetalleResponse obtener(@PathVariable Integer id, Authentication auth) {
        var ref = evaluaciones.referencia(id);
        return new EvaluacionDetalleResponse(EvaluacionResponse.from(evaluaciones.obtener(ref, auth)),
                preguntas.listarDeEvaluacion(ref, auth), materiales.listarDeEvaluacion(id, auth));
    }

    @PutMapping @PreAuthorize("hasRole('UTP')")
    public EvaluacionResponse actualizar(@PathVariable Integer id, @Valid @RequestBody EvaluacionEdicionRequest dto) {
        return EvaluacionResponse.from(evaluaciones.actualizarContenido(evaluaciones.referencia(id), dto));
    }

    @PatchMapping("/estado") @PreAuthorize("hasRole('UTP')")
    public EvaluacionResponse estado(@PathVariable Integer id, @RequestParam boolean activo) {
        return EvaluacionResponse.from(evaluaciones.cambiarEstado(evaluaciones.referencia(id), activo));
    }

    @DeleteMapping @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable Integer id) { evaluaciones.eliminar(evaluaciones.referencia(id)); }

    @GetMapping("/preguntas")
    public List<PreguntaResponse> listarPreguntas(@PathVariable Integer id, Authentication auth) {
        return preguntas.listarDeEvaluacion(evaluaciones.referencia(id), auth);
    }

    @PostMapping("/preguntas") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public PreguntaResponse crearPregunta(@PathVariable Integer id, @Valid @RequestBody PreguntaEnEvaluacionRequest dto) {
        return preguntas.crearEnEvaluacion(evaluaciones.referencia(id), dto);
    }

    @PutMapping("/preguntas/{idPregunta}") @PreAuthorize("hasRole('UTP')")
    public PreguntaResponse actualizarPregunta(@PathVariable Integer id, @PathVariable Integer idPregunta,
            @Valid @RequestBody PreguntaEnEvaluacionRequest dto) {
        return preguntas.actualizarEnEvaluacion(evaluaciones.referencia(id), idPregunta, dto);
    }

    @DeleteMapping("/preguntas/{idPregunta}") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarPregunta(@PathVariable Integer id, @PathVariable Integer idPregunta) {
        preguntas.eliminarEnEvaluacion(evaluaciones.referencia(id), idPregunta);
    }

    @GetMapping("/materiales")
    public List<MaterialResponse> listarMateriales(@PathVariable Integer id, Authentication auth) {
        return materiales.listarDeEvaluacion(id, auth);
    }

    @PostMapping("/materiales") @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse crearMaterial(@PathVariable Integer id, @Valid @RequestBody MaterialRequest dto) {
        return materiales.crearEnEvaluacion(id, dto);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String,String>> error(ResponseStatusException ex) {
        return ResponseEntity.status(ex.getStatusCode()).body(Map.of("message",
                ex.getReason()==null ? "No se pudo procesar la evaluación" : ex.getReason()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String,String>> relacionado(DataIntegrityViolationException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message",
                "La evaluación tiene contenido relacionado que debe conservarse"));
    }
}
