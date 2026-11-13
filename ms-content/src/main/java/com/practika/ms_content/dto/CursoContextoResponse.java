package com.practika.ms_content.dto;

/** Academic context for content; historical identifiers never change. */
public record CursoContextoResponse(Integer id, Integer idSeccion, Integer idAsignatura,
        Integer idPeriodoAcademico, Boolean activo, Boolean periodoActivo) { }
