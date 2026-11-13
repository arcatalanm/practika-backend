package com.practika.ms_auth.controller;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.access.prepost.PreAuthorize;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

import com.practika.ms_auth.dto.LoginRequestDTO;
import com.practika.ms_auth.dto.LoginResponseDTO;
import com.practika.ms_auth.dto.UsuarioRequestDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.service.AuthService;
import com.practika.ms_auth.service.UsuarioService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UsuarioService usuarioService;

    @PostMapping("/login")
    public LoginResponseDTO login(@Valid @RequestBody LoginRequestDTO dto) {
        return authService.login(dto);
    }

    /** Registro reservado a ADMIN; por esta ruta solo se crean estudiantes. */
    @PostMapping("/register")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public UsuarioResponseDTO registrar(@Valid @RequestBody UsuarioRequestDTO dto) {
        return usuarioService.registrar(dto);
    }

    @GetMapping("/me")
    @SecurityRequirement(name = "bearerAuth")
    public UsuarioResponseDTO perfil(Authentication authentication) {
        return authService.perfil(runAutenticado(authentication));
    }

    /** Identity already checked against the current account by the auth filter. */
    @GetMapping("/identity")
    @SecurityRequirement(name = "bearerAuth")
    public IdentityResponse identidad(Authentication authentication) {
        String rol = authentication.getAuthorities().iterator().next().getAuthority().substring(5);
        return new IdentityResponse(runAutenticado(authentication), rol);
    }

    public record IdentityResponse(Integer run, String rol) { }

    private Integer runAutenticado(Authentication authentication) {
        return Integer.valueOf(authentication.getName());
    }
}
