package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import com.practika.ms_content.model.TipoEvaluacion;
import jakarta.validation.constraints.*;

public record EvaluacionEnUnidadRequest(@NotNull TipoEvaluacion tipo,
        @NotBlank @Size(max = 150) String titulo, LocalDateTime fechaAplicacion,
        Boolean estadoActivo, @Min(1) @Max(20) Integer cantidadIntentos) {
    public EvaluacionRequest enUnidad(Integer idUnidad) {
        return new EvaluacionRequest(tipo, idUnidad, titulo, fechaAplicacion, estadoActivo, cantidadIntentos);
    }
}
