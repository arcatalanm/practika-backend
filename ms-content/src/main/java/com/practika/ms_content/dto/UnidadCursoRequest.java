package com.practika.ms_content.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record UnidadCursoRequest(@NotNull @Positive Integer idUnidad,
        @NotNull @Positive Integer idCurso) {}
