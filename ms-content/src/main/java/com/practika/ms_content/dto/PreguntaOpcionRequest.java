package com.practika.ms_content.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record PreguntaOpcionRequest(@Positive(message = "El id de la alternativa debe ser positivo") Integer id,
        @NotBlank(message = "Escribe el texto de cada alternativa") String texto,
        @NotNull(message = "Indica si cada alternativa es correcta") Boolean esCorrecta) {
}
