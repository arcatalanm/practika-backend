package com.practika.ms_content.service;

import com.practika.ms_content.model.Pregunta;
import com.practika.ms_content.model.TipoEvaluacion;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public record EvaluacionRef(TipoEvaluacion tipo, Integer id) {

    public static EvaluacionRef dePregunta(Pregunta pregunta) {
        if (pregunta.getIdActividad() != null) {
            return new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, pregunta.getIdActividad());
        }
        if (pregunta.getIdPrueba() != null) {
            return new EvaluacionRef(TipoEvaluacion.PRUEBA, pregunta.getIdPrueba());
        }
        throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                "No existe unidad de la pregunta con ID " + pregunta.getId());
    }
}
