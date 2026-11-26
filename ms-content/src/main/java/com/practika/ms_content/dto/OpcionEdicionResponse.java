package com.practika.ms_content.dto;

import com.practika.ms_content.model.Opcion;

public record OpcionEdicionResponse(Integer id, Integer idPregunta, String texto, Boolean esCorrecta) {
    public static OpcionEdicionResponse from(Opcion opcion) {
        return new OpcionEdicionResponse(opcion.getId(), opcion.getIdPregunta(), opcion.getTexto(), opcion.getEsCorrecta());
    }
}
