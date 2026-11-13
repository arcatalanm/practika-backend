package com.practika.ms_academic.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record CursoPortalRequest(
        @NotNull @Positive Integer idSeccion,
        @NotNull @Positive Integer idAsignatura,
        @NotNull @Positive Integer idPeriodoAcademico,
        @NotBlank @Size(max = 120) String nombre,
        String descripcion) {}
