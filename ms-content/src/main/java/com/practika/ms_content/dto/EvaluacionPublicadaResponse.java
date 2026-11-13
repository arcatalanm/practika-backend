package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import java.util.List;
import com.practika.ms_content.dto.UnidadDetalleResponse.*;

public record EvaluacionPublicadaResponse(Integer idEvaluacionAsignada,Integer idCursoPortal,
        Integer idPeriodoAcademico,Integer idSeccion,Integer version,Integer idActividad,Integer idPrueba,
        String titulo,Integer cantidadIntentos,LocalDateTime fechaAplicacion,LocalDateTime publicadaEn,
        Boolean activa,List<PreguntaDetalle> preguntas,List<MaterialDetalle> materiales) {
    public record Contenido(String titulo,Integer cantidadIntentos,LocalDateTime fechaAplicacion,
            List<PreguntaDetalle> preguntas,List<MaterialDetalle> materiales) {}
}
