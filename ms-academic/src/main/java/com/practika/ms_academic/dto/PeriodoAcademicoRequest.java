package com.practika.ms_academic.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record PeriodoAcademicoRequest(
        @NotBlank @Pattern(regexp = "\\d{4}-S[1-2]") String codigo,
        @NotBlank @Size(max = 60) String nombre) {}
