package com.practika.ms_auth.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

import com.practika.ms_auth.dto.EstadoRequestDTO;
import com.practika.ms_auth.dto.PasswordResetDTO;
import com.practika.ms_auth.dto.UsuarioRequestDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.dto.UsuarioUpdateDTO;
import com.practika.ms_auth.service.UsuarioService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth/usuarios")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESOR', 'UTP')")
    public List<UsuarioResponseDTO> listar(
            @RequestParam(required = false) Integer idSeccion,
            @RequestParam(required = false) String rol,
            @RequestParam(defaultValue = "false") boolean incluirInactivos) {
        return usuarioService.listar(idSeccion, rol, incluirInactivos);
    }

    @GetMapping("/{run}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESOR', 'UTP') or #run == authentication.principal")
    public UsuarioResponseDTO obtenerPorRun(@PathVariable Integer run) {
        return usuarioService.obtenerPorRun(run);
    }

    @GetMapping("/docentes/{run}/publico")
    public com.practika.ms_auth.dto.PersonaPublicaDTO obtenerDocentePublico(@PathVariable Integer run) {
        UsuarioResponseDTO usuario = usuarioService.obtenerPorRun(run);
        if (!"PROFESOR".equalsIgnoreCase(usuario.getRol()) || !Boolean.TRUE.equals(usuario.getActivo())) {
            throw new org.springframework.web.server.ResponseStatusException(HttpStatus.NOT_FOUND, "No existe un docente activo con ese RUN");
        }
        return new com.practika.ms_auth.dto.PersonaPublicaDTO(usuario.getRun(), usuario.getNombreCompleto(), usuario.getRol(), usuario.getImgPerfil());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponseDTO crear(@Valid @RequestBody UsuarioRequestDTO dto) {
        return usuarioService.crear(dto);
    }

    @PutMapping("/{run}")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponseDTO actualizar(@PathVariable Integer run, @Valid @RequestBody UsuarioUpdateDTO dto) {
        return usuarioService.actualizar(run, dto);
    }

    public record SeccionAsignada(Integer idSeccion) {}

    @PutMapping("/{run}/seccion") @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponseDTO asignarSeccion(@PathVariable Integer run, @RequestBody SeccionAsignada dto) {
        return usuarioService.asignarSeccion(run, dto.idSeccion());
    }

    /** Reseteo de contraseña: solo ADMIN. */
    @PutMapping("/{run}/password")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void restablecerPassword(
            @PathVariable Integer run,
            @Valid @RequestBody PasswordResetDTO dto) {
        usuarioService.restablecerPassword(run, dto);
    }

    /** Activa o desactiva un usuario (borrado lógico). */
    @PatchMapping("/{run}/estado")
    @PreAuthorize("hasRole('ADMIN')")
    public UsuarioResponseDTO cambiarEstado(
            @PathVariable Integer run,
            @Valid @RequestBody EstadoRequestDTO dto) {
        return usuarioService.cambiarEstado(run, dto.getActivo());
    }

    /** Borrado lógico: el usuario queda inactivo. */
    @DeleteMapping("/{run}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    public void eliminar(@PathVariable Integer run) {
        usuarioService.eliminar(run);
    }
}
