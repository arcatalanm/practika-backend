package com.practika.ms_content.dto;

import com.practika.ms_content.model.Evaluacion;

public record ActividadResponse(Integer id, Integer idUnidad, String titulo,
        Boolean estadoActivo, Integer cantidadIntentos) {
    public static ActividadResponse from(Evaluacion actividad) {
        return new ActividadResponse(actividad.getId(), actividad.getIdUnidad(), actividad.getTitulo(),
                actividad.getEstadoActivo(), actividad.getCantidadIntentos());
    }
}
