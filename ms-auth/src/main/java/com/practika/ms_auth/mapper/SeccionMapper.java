package com.practika.ms_auth.mapper;

import com.practika.ms_auth.dto.SeccionRequestDTO;
import com.practika.ms_auth.dto.SeccionResponseDTO;
import com.practika.ms_auth.model.NivelEducativo;
import com.practika.ms_auth.model.Seccion;

public final class SeccionMapper {
    private SeccionMapper() {}

    public static Seccion toEntity(SeccionRequestDTO dto, NivelEducativo nivel) {
        Seccion seccion = new Seccion();
        applyChanges(seccion, dto, nivel);
        return seccion;
    }

    public static void applyChanges(Seccion seccion, SeccionRequestDTO dto, NivelEducativo nivel) {
        seccion.setNivel(nivel);
    }

    public static SeccionResponseDTO toResponseDTO(Seccion seccion) {
        if (seccion == null) return null;
        seccion = seccion.actual();
        return SeccionResponseDTO.builder().id(seccion.getId()).nivelEducativo(seccion.getNivel().getNombre())
                .activo(!Boolean.FALSE.equals(seccion.getActivo())).build();
    }
}
