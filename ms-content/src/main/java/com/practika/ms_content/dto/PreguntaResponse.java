package com.practika.ms_content.dto;

import java.math.BigDecimal;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.practika.ms_content.model.Pregunta;

public record PreguntaResponse(Integer id, Integer idActividad, Integer idPrueba, String texto,
        String tipo, BigDecimal puntajeMaximo,
        @JsonInclude(JsonInclude.Include.NON_NULL) List<OpcionResponse> opciones,
        @JsonInclude(JsonInclude.Include.NON_NULL) List<MaterialResponse> materiales) {
    public PreguntaResponse(Integer id, Integer idActividad, Integer idPrueba, String texto,
            String tipo, BigDecimal puntajeMaximo, List<OpcionResponse> opciones) {
        this(id, idActividad, idPrueba, texto, tipo, puntajeMaximo, opciones, null);
    }
    public PreguntaResponse(Integer id, Integer idActividad, Integer idPrueba, String texto,
            String tipo, BigDecimal puntajeMaximo) {
        this(id, idActividad, idPrueba, texto, tipo, puntajeMaximo, null);
    }

    public static PreguntaResponse from(Pregunta pregunta) {
        return new PreguntaResponse(pregunta.getId(), pregunta.getIdActividad(), pregunta.getIdPrueba(),
                pregunta.getTexto(), pregunta.getTipo(), pregunta.getPuntajeMaximo());
    }

    public static PreguntaResponse conOpciones(Pregunta pregunta, List<OpcionResponse> opciones) {
        return new PreguntaResponse(pregunta.getId(), pregunta.getIdActividad(), pregunta.getIdPrueba(),
                pregunta.getTexto(), pregunta.getTipo(), pregunta.getPuntajeMaximo(), opciones);
    }
}
