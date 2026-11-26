package com.practika.ms_content.dto;

public record CursoContextoResponse(Integer id, Integer idSeccion, Integer idAsignatura,
        Integer idPeriodoAcademico, Boolean activo, Boolean periodoActivo) { }
