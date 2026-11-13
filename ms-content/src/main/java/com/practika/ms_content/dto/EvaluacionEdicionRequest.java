package com.practika.ms_content.dto;

import java.time.LocalDateTime;
import jakarta.validation.constraints.*;

/** Type and unit are inherited from the evaluation being edited. */
public record EvaluacionEdicionRequest(@NotBlank @Size(max = 150) String titulo,
        LocalDateTime fechaAplicacion, Boolean estadoActivo, @Min(1) @Max(20) Integer cantidadIntentos) { }
