package com.practika.ms_content.service;

/** Parent lookup independent of the current activity/test tables. */
public interface EvaluacionGateway {
    Datos obtener(EvaluacionRef ref);
    com.practika.ms_content.model.Evaluacion buscar(EvaluacionRef ref);
    com.practika.ms_content.model.Evaluacion buscarPorId(Integer id);

    record Datos(EvaluacionRef referencia, Integer idUnidad, Boolean estadoActivo) {
    }
}
