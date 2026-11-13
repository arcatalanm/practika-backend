package com.practika.ms_content.controller;

import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.PreguntaService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@RequiredArgsConstructor
public class PreguntaController {
    private final PreguntaService service;

    @GetMapping("/preguntas")
    public List<PreguntaResponse> listarPreguntas(@RequestParam(required = false) Integer idActividad,
            @RequestParam(required = false) Integer idPrueba, Authentication authentication) {
        return service.listar(idActividad, idPrueba, authentication);
    }

    @GetMapping("/preguntas/{id}")
    public PreguntaResponse obtenerPregunta(@PathVariable Integer id, Authentication authentication) {
        return service.obtener(id, authentication);
    }

    @PostMapping("/preguntas")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public PreguntaResponse crearPregunta(@Valid @RequestBody PreguntaRequest dto) {
        return service.crear(dto);
    }

    @PutMapping("/preguntas/{id}")
    @PreAuthorize("hasRole('UTP')")
    public PreguntaResponse actualizarPregunta(@PathVariable Integer id, @Valid @RequestBody PreguntaRequest dto) {
        return service.actualizar(id, dto);
    }

    @DeleteMapping("/preguntas/{id}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarPregunta(@PathVariable Integer id) {
        service.eliminar(id);
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> error(ResponseStatusException ex) {
        return ResponseEntity.status(ex.getStatusCode()).body(Map.of("message",
                ex.getReason() == null ? "No se pudo guardar la pregunta" : ex.getReason()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> datosInvalidos(MethodArgumentNotValidException ex) {
        var error = ex.getBindingResult().getFieldError();
        String mensaje = error == null || error.getDefaultMessage() == null
                ? "Revisa los datos de la pregunta" : error.getDefaultMessage();
        return ResponseEntity.badRequest().body(Map.of("message", mensaje));
    }
}
