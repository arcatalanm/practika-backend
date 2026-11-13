package com.practika.ms_content.dto;

import com.practika.ms_content.model.TipoMaterial;
import com.practika.ms_content.model.TipoPregunta;

public record CatalogoResponse(Integer id, String codigo, String nombre, Boolean activo) {
    public static CatalogoResponse from(TipoMaterial tipo) {
        return new CatalogoResponse(tipo.getId(), tipo.getCodigo(), tipo.getNombre(), tipo.getActivo());
    }

    public static CatalogoResponse from(TipoPregunta tipo) {
        return new CatalogoResponse(tipo.getId(), tipo.getCodigo(), tipo.getNombre(), tipo.getActivo());
    }
}
