package com.practika.ms_grading.dto;
import java.math.BigDecimal;
import jakarta.validation.constraints.*;
public record ObservacionRequest(@NotNull @Positive Integer idCursoPortal, Integer idActividad, Integer idPrueba,
        @NotNull @Positive Integer runEstudiante,
        @NotBlank String texto, @NotNull @DecimalMin("0.00") @DecimalMax("100.00") @Digits(integer=3,fraction=2) BigDecimal porcentajeLogro) {}
