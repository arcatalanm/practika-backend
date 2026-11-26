package com.practika.ms_content.service;

public interface EvaluacionGateway {
    Datos obtener(EvaluacionRef ref);
    com.practika.ms_content.model.Evaluacion buscar(EvaluacionRef ref);
    com.practika.ms_content.model.Evaluacion buscarPorId(Integer id);

    record Datos(EvaluacionRef referencia, Integer idUnidad, Boolean estadoActivo) {
    }
}
