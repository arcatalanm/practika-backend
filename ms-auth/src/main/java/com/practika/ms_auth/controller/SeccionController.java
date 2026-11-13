package com.practika.ms_auth.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_auth.dto.EstadoRequestDTO;
import com.practika.ms_auth.dto.SeccionRequestDTO;
import com.practika.ms_auth.dto.SeccionResponseDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.service.SeccionService;
import com.practika.ms_auth.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/auth/secciones") @RequiredArgsConstructor
public class SeccionController {
    private final SeccionService secciones;
    private final UsuarioService usuarios;
    private final com.practika.ms_auth.service.MatriculaService matriculas;

    @GetMapping
    public List<SeccionResponseDTO> listar(@RequestParam(defaultValue = "false") boolean incluirInactivas) {
        return secciones.listar(incluirInactivas);
    }

    @GetMapping("/{id}")
    public SeccionResponseDTO obtener(@PathVariable Integer id) { return secciones.obtener(id); }

    @GetMapping("/{id}/participantes")
    public List<UsuarioResponseDTO> participantes(@PathVariable Integer id,
            @RequestParam(defaultValue="false") boolean incluirHistoricos,Authentication authentication) {
        boolean staff = authentication.getAuthorities().stream().anyMatch(a ->
                List.of("ROLE_ADMIN", "ROLE_PROFESOR", "ROLE_UTP").contains(a.getAuthority()));
        if (!staff) {
            if (!matriculas.pertenece(Integer.valueOf(authentication.getName()),id,false)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a los participantes de esta sección");
            }
        }
        return matriculas.participantes(id,incluirHistoricos).stream()
                .filter(usuario -> incluirHistoricos || (Boolean.TRUE.equals(usuario.getActivo())
                        && "ESTUDIANTE".equals(usuario.getRol().getCodigo())))
                .map(com.practika.ms_auth.mapper.UsuarioMapper::toResponseDTO).toList();
    }

    @GetMapping("/{id}/docentes")
    public List<com.practika.ms_auth.dto.PersonaPublicaDTO> docentes(@PathVariable Integer id, Authentication auth) {
        Integer section = secciones.obtener(id).getId();
        var user = usuarios.obtenerPorRun(Integer.valueOf(auth.getName()));
        boolean gestor = List.of("ADMIN", "UTP").contains(user.getRol());
        if (!gestor && (user.getSeccion() == null || !section.equals(user.getSeccion().getId()))
                && !matriculas.pertenece(user.getRun(), section, false))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No perteneces a esta sección");
        return usuarios.listar(section,"PROFESOR",false).stream()
                .map(u -> new com.practika.ms_auth.dto.PersonaPublicaDTO(u.getRun(),u.getNombreCompleto(),u.getRol(),u.getImgPerfil())).toList();
    }

    @PostMapping @ResponseStatus(HttpStatus.CREATED) @PreAuthorize("hasRole('ADMIN')")
    public SeccionResponseDTO crear(@Valid @RequestBody SeccionRequestDTO dto) { return secciones.crear(dto); }

    @PutMapping("/{id}") @PreAuthorize("hasRole('ADMIN')")
    public SeccionResponseDTO actualizar(@PathVariable Integer id, @Valid @RequestBody SeccionRequestDTO dto) {
        return secciones.actualizar(id, dto);
    }

    @PatchMapping("/{id}/estado") @PreAuthorize("hasRole('ADMIN')")
    public SeccionResponseDTO estado(@PathVariable Integer id, @Valid @RequestBody EstadoRequestDTO dto) {
        return secciones.cambiarEstado(id, dto.getActivo());
    }
}
