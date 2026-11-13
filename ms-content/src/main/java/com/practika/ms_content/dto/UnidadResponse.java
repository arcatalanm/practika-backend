package com.practika.ms_content.dto;

import com.practika.ms_content.model.Unidad;

public record UnidadResponse(Integer id, Integer idAsignatura, Integer idObjetivo, String titulo, String descripcion) {
    public static UnidadResponse from(Unidad unidad) {
        return new UnidadResponse(unidad.getId(), unidad.getIdAsignatura(), unidad.getIdObjetivo(),
                unidad.getTitulo(), unidad.getDescripcion());
    }
}
