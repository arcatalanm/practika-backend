package com.practika.ms_content.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

/** Subject is inherited from the course; accepted optionally for existing clients. */
public record UnidadEnCursoRequest(@Positive Integer idAsignatura,
        @NotNull @Positive Integer idObjetivo, @NotBlank @Size(max = 150) String titulo,
        String descripcion) { }
