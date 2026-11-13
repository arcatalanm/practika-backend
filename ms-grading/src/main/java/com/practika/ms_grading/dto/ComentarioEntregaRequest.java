package com.practika.ms_grading.dto;
import jakarta.validation.constraints.*;
public record ComentarioEntregaRequest(@NotNull @Size(max=5000) String comentario) {}
