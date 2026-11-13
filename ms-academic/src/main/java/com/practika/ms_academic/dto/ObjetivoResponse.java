package com.practika.ms_academic.dto;

import com.practika.ms_academic.model.ObjetivoAprendizaje;

public record ObjetivoResponse(Integer id, AsignaturaResponse asignatura, String descripcion, String codigo) {
    public static ObjetivoResponse from(ObjetivoAprendizaje objetivo) {
        return new ObjetivoResponse(objetivo.getId(), AsignaturaResponse.from(objetivo.getAsignatura()),
                objetivo.getDescripcion(), objetivo.getCodigo());
    }
}
