package com.practika.ms_content.dto;
import jakarta.validation.constraints.*;
public record ActividadRequest(@NotNull @Positive Integer idUnidad,
        @NotBlank @Size(max=150) String titulo, Boolean estadoActivo,
        @NotNull @Min(1) @Max(20) Integer cantidadIntentos) {}
