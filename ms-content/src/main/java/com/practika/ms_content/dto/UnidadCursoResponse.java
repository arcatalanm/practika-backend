package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import com.practika.ms_content.model.UnidadCurso;

public record UnidadCursoResponse(Integer id, Integer idUnidad, Integer idCurso, Integer runProfesor,
        LocalDateTime asignadoEn, Boolean publicacionInicializada) {
    public static UnidadCursoResponse from(UnidadCurso asignacion) {
        return new UnidadCursoResponse(asignacion.getId(), asignacion.getIdUnidad(), asignacion.getIdCurso(),
                asignacion.getRunProfesor(), asignacion.getAsignadoEn(), asignacion.getPublicacionInicializada());
    }
}
