package com.practika.ms_content.dto;
import jakarta.validation.constraints.NotBlank;
public record OpcionRequest(@NotBlank String texto, Boolean esCorrecta) {}
