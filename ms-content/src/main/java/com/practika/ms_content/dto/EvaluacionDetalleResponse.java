package com.practika.ms_content.dto;

import java.util.List;

public record EvaluacionDetalleResponse(EvaluacionResponse evaluacion, List<PreguntaResponse> preguntas,
        List<MaterialResponse> materiales) {
    public EvaluacionDetalleResponse(EvaluacionResponse evaluacion, List<PreguntaResponse> preguntas) {
        this(evaluacion, preguntas, List.of());
    }
}
