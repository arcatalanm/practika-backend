package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import com.practika.ms_content.model.Prueba;
import com.practika.ms_content.model.Evaluacion;

public record PruebaResponse(Integer id, Integer idUnidad, String titulo, LocalDateTime fechaAplicacion,
        Boolean estadoActivo, Integer cantidadIntentos) {
    public static PruebaResponse from(Evaluacion prueba) {
        return new PruebaResponse(prueba.getId(), prueba.getIdUnidad(), prueba.getTitulo(),
                prueba instanceof Prueba fechada ? fechada.getFechaAplicacion() : null, prueba.getEstadoActivo(), prueba.getCantidadIntentos());
    }
}
