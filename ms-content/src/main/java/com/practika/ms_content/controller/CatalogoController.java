package com.practika.ms_content.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.service.CatalogoService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
@PreAuthorize("hasAnyRole('UTP','PROFESOR')")
@RequiredArgsConstructor
public class CatalogoController {
    private final CatalogoService service;

    @GetMapping("/catalogos/tipos-material")
    public List<CatalogoResponse> listarTiposMaterial() {
        return service.listarTiposMaterial();
    }

    @GetMapping("/catalogos/tipos-pregunta")
    public List<CatalogoResponse> listarTiposPregunta() {
        return service.listarTiposPregunta();
    }
}
