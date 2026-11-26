package com.practika.ms_content.controller;

import com.practika.ms_content.dto.TiempoResponse;
import com.practika.ms_content.service.TiempoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/content/tiempo")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class TiempoController {
    private final TiempoService service;

    @GetMapping
    @Operation(summary = "Tiempo actual en la ubicacion fija de la sede",
            description = "Consulta Open-Meteo desde el backend. Incluye temperatura actual y extrema diaria en Celsius, hora local y fuente. Cache compartida en memoria de diez minutos.")
    public ResponseEntity<TiempoResponse> obtener() {
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(service.obtener());
    }
}
