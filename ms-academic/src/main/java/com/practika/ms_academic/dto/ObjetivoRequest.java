package com.practika.ms_academic.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record ObjetivoRequest(@NotNull @Positive Integer idAsignatura, @NotBlank String descripcion, @NotBlank @jakarta.validation.constraints.Pattern(regexp="[A-Za-z0-9-]{3,40}") String codigo) {}
