package com.practika.ms_content.controller;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.EvaluacionPublicadaResponse;
import com.practika.ms_content.service.EvaluacionPublicadaService;

/** Only ms-grading may retrieve the answer key, using the submitting student's session. */
@RestController
@RequestMapping("/internal/content/correccion")
public class CorreccionInternaController {
    private final EvaluacionPublicadaService service;
    private final String token;

    public CorreccionInternaController(EvaluacionPublicadaService service,
            @Value("${GRADING_INTERNAL_TOKEN:}") String token) {
        this.service = service;
        this.token = token;
    }

    @GetMapping("/{id}/estudiantes/{run}")
    @PreAuthorize("hasRole('ESTUDIANTE')")
    public ResponseEntity<EvaluacionPublicadaResponse> obtener(@PathVariable Integer id,
            @PathVariable Integer run, @RequestHeader("X-Grading-Token") String supplied,
            Authentication auth) {
        if (token.isBlank()) throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Configura GRADING_INTERNAL_TOKEN en ms-content y ms-grading");
        if (!MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8), supplied.getBytes(StandardCharsets.UTF_8)))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Acceso interno no autorizado");
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(service.paraCorreccion(id, run, auth));
    }
}
