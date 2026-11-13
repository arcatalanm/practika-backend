package com.practika.ms_content.dto;

import java.math.BigDecimal;
import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

public record PreguntaRequest(Integer idActividad, Integer idPrueba,
        @NotBlank(message = "Escribe el enunciado de la pregunta") String texto,
        @NotBlank(message = "Indica el tipo de pregunta")
        @Size(max = 30, message = "El tipo de pregunta no puede superar 30 caracteres") String tipo,
        @NotNull(message = "Indica el puntaje de la pregunta")
        @DecimalMin(value = "0.01", message = "El puntaje debe ser mayor que cero")
        @Digits(integer = 3, fraction = 2, message = "El puntaje admite hasta 3 enteros y 2 decimales") BigDecimal puntajeMaximo,
        @Valid List<@NotNull(message = "No envíes alternativas vacías") PreguntaOpcionRequest> opciones) {
    public PreguntaRequest(Integer idActividad, Integer idPrueba, String texto, String tipo, BigDecimal puntajeMaximo) {
        this(idActividad, idPrueba, texto, tipo, puntajeMaximo, null);
    }
}
