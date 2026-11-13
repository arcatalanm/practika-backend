package com.practika.ms_grading.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record EntregaResponse(Integer id, Integer runEstudiante, Integer idActividad, Integer idPrueba, Integer numeroIntento,
        LocalDateTime fechaEntrega, String estado, boolean permiteReintento, BigDecimal puntajeTotal,
        LocalDateTime fechaRevision, String comentario, List<Item> respuestas,
        Integer idEvaluacionAsignada,Integer idCursoPortal,Integer idPeriodoAcademico,Integer idSeccion,
        String tituloEvaluacion,Integer version,boolean snapshotReconstruido,
        List<com.practika.ms_grading.client.ContentClient.PreguntaSnapshot> preguntas) {
    public record Item(Integer idRespuesta, Integer idPregunta, String textoDesarrollo, List<Integer> idsOpciones,
            BigDecimal puntajeObtenido, String estadoRevision) {}
}
