package com.practika.ms_content.dto;
import java.time.LocalDateTime;
import jakarta.validation.constraints.*;
public record PruebaRequest(@NotNull @Positive Integer idUnidad,
        @NotBlank @Size(max=150) String titulo, @NotNull LocalDateTime fechaAplicacion,
        Boolean estadoActivo, @NotNull @Min(1) @Max(20) Integer cantidadIntentos) {}
