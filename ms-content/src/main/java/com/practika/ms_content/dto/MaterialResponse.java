package com.practika.ms_content.dto;

import com.practika.ms_content.model.Material;

public record MaterialResponse(Integer id, Integer idActividad, Integer idPregunta, String tipo,
        String contenidoUrl, String titulo, String contenidoTexto, Boolean activo) {
    public static MaterialResponse from(Material material) {
        return new MaterialResponse(material.getId(), material.getIdActividad(), material.getIdPregunta(),
                material.getTipo(), material.getContenidoUrl(), material.getTitulo(),
                material.getContenidoTexto(), material.getActivo());
    }
}
