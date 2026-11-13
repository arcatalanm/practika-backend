package com.practika.ms_grading.dto;

import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

public record EntregaRequest(@NotNull @Positive Integer runEstudiante,
        @Positive Integer idActividad, @Positive Integer idPrueba,
        @NotNull @Min(1) Integer numeroIntento,
        @NotEmpty @Size(max=1000) List<@NotNull @Valid Item> respuestas,
        @NotNull @Positive Integer idEvaluacionAsignada) {
    public record Item(@NotNull @Positive Integer idPregunta, String textoDesarrollo,
            List<@NotNull @Positive Integer> idsOpciones) {}
}
