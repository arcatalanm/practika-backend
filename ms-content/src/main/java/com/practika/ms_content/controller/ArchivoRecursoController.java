package com.practika.ms_content.controller;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.springframework.core.io.*;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.MaterialResponse;
import com.practika.ms_content.service.ArchivoRecursoService;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/content") @RequiredArgsConstructor
public class ArchivoRecursoController {
    private final ArchivoRecursoService service;

    @PostMapping(value="/preguntas/{id}/archivos",consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse subir(@PathVariable Integer id, @RequestPart("archivo") MultipartFile archivo) {
        return MaterialResponse.from(service.subir(id, archivo));
    }

    @PostMapping(value="/actividades/{id}/archivos",consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse subirActividad(@PathVariable Integer id, @RequestPart("archivo") MultipartFile archivo) {
        return MaterialResponse.from(service.subirActividad(id, archivo));
    }

    @GetMapping("/recursos/archivos/{id}")
    // Both activity and test attachments now share an evaluation owner.
    public ResponseEntity<Resource> obtener(@PathVariable String id,Authentication auth) {
        var archivo=service.obtener(id,auth);
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(archivo.getTipoContenido())).cacheControl(CacheControl.noStore())
            .header("X-Content-Type-Options","nosniff")
            .header(HttpHeaders.CONTENT_DISPOSITION,ContentDisposition.inline().filename(archivo.getNombre(),StandardCharsets.UTF_8).build().toString())
            .body(new ByteArrayResource(archivo.getContenido()));
    }

    @PostMapping(value="/autoria/evaluaciones/{id}/archivos",consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('UTP')") @ResponseStatus(HttpStatus.CREATED)
    public MaterialResponse subirEvaluacion(@PathVariable Integer id, @RequestPart("archivo") MultipartFile archivo) {
        return MaterialResponse.from(service.subirEvaluacion(id, archivo));
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String,String>> error(ResponseStatusException ex) {
        return ResponseEntity.status(ex.getStatusCode()).body(Map.of("message",ex.getReason()==null ? "No se pudo procesar el recurso" : ex.getReason()));
    }
}
