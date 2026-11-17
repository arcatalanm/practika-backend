package com.practika.ms_content.controller;

import java.util.concurrent.TimeUnit;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.practika.ms_content.dto.UnidadResponse;
import com.practika.ms_content.service.UnidadImagenService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/content") @SecurityRequirement(name = "bearerAuth") @RequiredArgsConstructor
public class UnidadImagenController {
    private final UnidadImagenService service;

    @PutMapping(value = "/unidades/{id}/imagen", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('UTP')")
    public UnidadResponse guardar(@PathVariable Integer id, @RequestPart("imagen") MultipartFile imagen) {
        return service.guardar(id, imagen);
    }

    @GetMapping("/unidades/{id}/imagen")
    public ResponseEntity<byte[]> obtener(@PathVariable Integer id, Authentication auth) {
        var img = service.obtener(id, auth);
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(img.getTipoContenido()))
                .cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS).cachePrivate())
                .header("X-Content-Type-Options", "nosniff").body(img.getContenido());
    }
}
