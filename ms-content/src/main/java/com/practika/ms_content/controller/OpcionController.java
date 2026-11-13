package com.practika.ms_content.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
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
public class OpcionController {
    private final PreguntaService service;

    @GetMapping("/preguntas/{id}/opciones")
    public List<OpcionResponse> listarOpciones(@PathVariable Integer id, Authentication authentication) {
        return service.listarOpciones(id, authentication);
    }

    @PostMapping("/preguntas/{id}/opciones")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.CREATED)
    public OpcionEdicionResponse crearOpcion(@PathVariable Integer id, @Valid @RequestBody OpcionRequest dto) {
        return service.crearOpcion(id, dto);
    }

    @PutMapping("/opciones/{id}")
    @PreAuthorize("hasRole('UTP')")
    public OpcionEdicionResponse actualizarOpcion(@PathVariable Integer id, @Valid @RequestBody OpcionRequest dto) {
        return service.actualizarOpcion(id, dto);
    }

    @DeleteMapping("/opciones/{id}")
    @PreAuthorize("hasRole('UTP')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarOpcion(@PathVariable Integer id) {
        service.eliminarOpcion(id);
    }
}
