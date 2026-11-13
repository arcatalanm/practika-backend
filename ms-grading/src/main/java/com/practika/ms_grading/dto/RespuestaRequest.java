package com.practika.ms_grading.dto;
import java.util.List;
import jakarta.validation.constraints.*;
public record RespuestaRequest(@NotNull @Positive Integer runEstudiante, @NotNull @Positive Integer idPregunta,
        @NotNull @Min(1) Integer numeroIntento, String textoDesarrollo, List<@Positive Integer> idsOpciones) {}
