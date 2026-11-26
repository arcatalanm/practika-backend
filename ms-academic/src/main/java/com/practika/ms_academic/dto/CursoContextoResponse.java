package com.practika.ms_academic.dto;

public record CursoContextoResponse(Integer id, Integer idSeccion, Integer idAsignatura,
        Integer idPeriodoAcademico, Boolean activo, Boolean periodoActivo) { }
