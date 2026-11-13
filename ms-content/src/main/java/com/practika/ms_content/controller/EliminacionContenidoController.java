package com.practika.ms_content.controller;

import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.service.EvaluacionService;
import com.practika.ms_content.service.EvaluacionRef;
import com.practika.ms_content.model.TipoEvaluacion;
import com.practika.ms_content.service.UnidadService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasRole('UTP')")
@RequiredArgsConstructor
public class EliminacionContenidoController {
    private final EvaluacionService evaluaciones;
    private final UnidadService unidades;

    @DeleteMapping("/actividades/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarActividad(@PathVariable Integer id) {
        evaluaciones.eliminar(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id));
    }

    @DeleteMapping("/pruebas/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarPrueba(@PathVariable Integer id) {
        evaluaciones.eliminar(new EvaluacionRef(TipoEvaluacion.PRUEBA, id));
    }

    @DeleteMapping("/unidades/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarUnidad(@PathVariable Integer id) {
        unidades.eliminar(id);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> error(ResponseStatusException ex) {
        return ResponseEntity.status(ex.getStatusCode()).body(Map.of("message",
                ex.getReason() == null ? "No se pudo eliminar el contenido" : ex.getReason()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> contenidoRelacionado(DataIntegrityViolationException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message",
                "No se puede eliminar: hay contenido relacionado que debe conservarse"));
    }
}
