package com.practika.ms_content.dto;

import java.math.BigDecimal;
import java.util.List;
import com.practika.ms_content.service.EvaluacionRef;
import com.practika.ms_content.model.TipoEvaluacion;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

public record PreguntaEnEvaluacionRequest(@NotBlank String texto, @NotBlank @Size(max = 30) String tipo,
        @DecimalMin("0.01") @Digits(integer = 3, fraction = 2) BigDecimal puntajeMaximo,
        @Valid List<@NotNull PreguntaOpcionRequest> opciones) {
    public PreguntaRequest enEvaluacion(EvaluacionRef ref) {
        return new PreguntaRequest(ref.tipo() == TipoEvaluacion.ACTIVIDAD ? ref.id() : null,
                ref.tipo() == TipoEvaluacion.PRUEBA ? ref.id() : null, texto, tipo,
                puntajeMaximo == null ? BigDecimal.ONE : puntajeMaximo, opciones);
    }
}
