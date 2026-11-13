package com.practika.ms_auth.controller;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.practika.ms_auth.dto.CatalogoResponseDTO;
import com.practika.ms_auth.repository.NivelEducativoRepository;
import com.practika.ms_auth.repository.RolRepository;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth/catalogos")
@RequiredArgsConstructor
public class CatalogoController {
    private final RolRepository roles;
    private final NivelEducativoRepository niveles;

    @GetMapping("/roles")
    public List<CatalogoResponseDTO> roles() {
        return roles.findAll().stream()
                .map(r -> new CatalogoResponseDTO(r.getId(), r.getCodigo(), r.getNombre()))
                .toList();
    }

    @GetMapping("/niveles-educativos")
    public List<CatalogoResponseDTO> niveles() {
        return niveles.findByActivoTrueOrderByIdAsc().stream()
                .sorted(java.util.Comparator.comparing(n -> n.getCodigo()))
                .map(n -> new CatalogoResponseDTO(n.getId(), n.getCodigo(), n.getNombre()))
                .toList();
    }
}
