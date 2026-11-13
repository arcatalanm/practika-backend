package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import com.practika.ms_content.model.TipoEvaluacion;
import jakarta.validation.constraints.*;

public record EvaluacionRequest(@NotNull TipoEvaluacion tipo, @NotNull @Positive Integer idUnidad,
        @NotBlank @Size(max = 150) String titulo, LocalDateTime fechaAplicacion,
        Boolean estadoActivo, @Min(1) @Max(20) Integer cantidadIntentos) {
    public static EvaluacionRequest deActividad(ActividadRequest dto) {
        return new EvaluacionRequest(TipoEvaluacion.ACTIVIDAD, dto.idUnidad(), dto.titulo(), null,
                dto.estadoActivo(), dto.cantidadIntentos());
    }

    public static EvaluacionRequest dePrueba(PruebaRequest dto) {
        return new EvaluacionRequest(TipoEvaluacion.PRUEBA, dto.idUnidad(), dto.titulo(), dto.fechaAplicacion(),
                dto.estadoActivo(), dto.cantidadIntentos());
    }
}
