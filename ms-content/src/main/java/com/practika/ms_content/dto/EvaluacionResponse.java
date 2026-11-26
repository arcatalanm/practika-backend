package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import com.practika.ms_content.model.Evaluacion;
import com.practika.ms_content.model.Prueba;
import com.practika.ms_content.model.TipoEvaluacion;

public record EvaluacionResponse(Integer idEvaluacion, Integer id, TipoEvaluacion tipo, Integer idUnidad, String titulo,
        LocalDateTime fechaAplicacion, Boolean estadoActivo, Integer cantidadIntentos) {
    public static EvaluacionResponse from(Evaluacion evaluacion) {
        return new EvaluacionResponse(evaluacion.getIdEvaluacion(), evaluacion.getId(), evaluacion.getTipoEvaluacion(),
                evaluacion.getIdUnidad(), evaluacion.getTitulo(),
                evaluacion instanceof Prueba prueba ? prueba.getFechaAplicacion() : null,
                evaluacion.getEstadoActivo(), evaluacion.getCantidadIntentos());
    }
}
