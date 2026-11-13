package com.practika.ms_grading.dto;
import java.math.BigDecimal;
import jakarta.validation.constraints.*;
public record RevisionRequest(@NotNull @DecimalMin("0.00") @Digits(integer=3,fraction=2) BigDecimal puntajeObtenido,
        @NotBlank @Pattern(regexp="(?i)REVISADA|PENDIENTE") String estadoRevision) {}
