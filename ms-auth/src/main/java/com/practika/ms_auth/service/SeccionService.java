package com.practika.ms_auth.service;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.practika.ms_auth.dto.SeccionRequestDTO;
import com.practika.ms_auth.dto.SeccionResponseDTO;
import com.practika.ms_auth.exception.BadRequestException;
import com.practika.ms_auth.exception.ResourceNotFoundException;
import com.practika.ms_auth.mapper.SeccionMapper;
import com.practika.ms_auth.model.NivelEducativo;
import com.practika.ms_auth.model.Seccion;
import com.practika.ms_auth.repository.NivelEducativoRepository;
import com.practika.ms_auth.repository.SeccionRepository;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class SeccionService {
    private final SeccionRepository secciones;
    private final NivelEducativoRepository niveles;

    @Transactional(readOnly = true)
    public List<SeccionResponseDTO> listar(boolean incluirInactivas) {
        List<Seccion> items = incluirInactivas ? secciones.findAll().stream()
                .filter(s -> s.getCanonica() == null && Boolean.TRUE.equals(s.getNivel().getActivo()))
                .sorted(java.util.Comparator.comparing(s -> s.getNivel().getCodigo())).toList() : secciones.findActivas();
        return items.stream().map(SeccionMapper::toResponseDTO).toList();
    }

    @Transactional(readOnly = true)
    public SeccionResponseDTO obtener(Integer id) { return SeccionMapper.toResponseDTO(buscar(id)); }

    @Transactional
    public SeccionResponseDTO crear(SeccionRequestDTO dto) {
        NivelEducativo nivel = buscarNivel(dto.getNivelEducativo());
        if (secciones.existsByNivel_IdAndCanonicaIsNull(nivel.getId()))
            throw new com.practika.ms_auth.exception.ConflictException("Ya existe una sección para este nivel; puedes reactivarla si está inactiva");
        Seccion s = SeccionMapper.toEntity(dto, nivel);

        s.setActivo(true);
        return SeccionMapper.toResponseDTO(secciones.save(s));
    }

    @Transactional
    public SeccionResponseDTO actualizar(Integer id, SeccionRequestDTO dto) {
        Seccion s = buscar(id);
        NivelEducativo nivel=buscarNivel(dto.getNivelEducativo());
        if (!s.getNivel().getId().equals(nivel.getId()))
            throw new BadRequestException("El nivel identifica a la sección y no se puede cambiar");
        return SeccionMapper.toResponseDTO(secciones.save(s));
    }

    @Transactional
    public SeccionResponseDTO cambiarEstado(Integer id, boolean activo) {
        Seccion s = buscar(id);
        if (activo && !Boolean.TRUE.equals(s.getNivel().getActivo()))
            throw new BadRequestException("Solo se admiten niveles de primero a octavo básico");
        s.setActivo(activo);
        return SeccionMapper.toResponseDTO(secciones.save(s));
    }

    private Seccion buscar(Integer id) {
        return secciones.findById(id).orElseThrow(() -> new ResourceNotFoundException("No existe la sección con ID " + id)).actual();
    }

    private NivelEducativo buscarNivel(String valor) {
        String v = valor == null ? "" : valor.trim();
        return niveles.findByCodigoIgnoreCaseOrNombreIgnoreCase(v, v).filter(n -> !Boolean.FALSE.equals(n.getActivo()))
                .orElseThrow(() -> new BadRequestException("Nivel educativo no válido o inactivo: " + valor));
    }

}
