package com.practika.ms_academic.dto;

import com.practika.ms_academic.model.Asignatura;

public record AsignaturaResponse(Integer id, String nombre, Boolean activo) {
    public static AsignaturaResponse from(Asignatura asignatura) {
        return new AsignaturaResponse(asignatura.getId(), asignatura.getNombre(), asignatura.getActivo());
    }
}
