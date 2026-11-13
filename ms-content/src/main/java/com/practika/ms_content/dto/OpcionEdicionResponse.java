package com.practika.ms_content.dto;

import com.practika.ms_content.model.Opcion;

/** Creation/update historically include the parent, unlike the list response. */
public record OpcionEdicionResponse(Integer id, Integer idPregunta, String texto, Boolean esCorrecta) {
    public static OpcionEdicionResponse from(Opcion opcion) {
        return new OpcionEdicionResponse(opcion.getId(), opcion.getIdPregunta(), opcion.getTexto(), opcion.getEsCorrecta());
    }
}
