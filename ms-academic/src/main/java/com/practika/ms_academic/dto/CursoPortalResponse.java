package com.practika.ms_academic.dto;

import java.util.List;

public record CursoPortalResponse(Integer id, Integer idSeccion, String seccion,
        Integer idAsignatura, String asignatura, Integer idPeriodoAcademico, String periodo,
        String nombre, String descripcion, Boolean activo, List<DocentePortalResponse> docentes) {}
