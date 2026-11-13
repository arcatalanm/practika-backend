package com.practika.ms_academic.dto;

import com.practika.ms_academic.model.PeriodoAcademico;

public record PeriodoAcademicoResponse(Integer id, String codigo, String nombre, Boolean activo) {
    public static PeriodoAcademicoResponse from(PeriodoAcademico periodo) {
        return new PeriodoAcademicoResponse(periodo.getId(), periodo.getCodigo(), periodo.getNombre(), periodo.getActivo());
    }
}
