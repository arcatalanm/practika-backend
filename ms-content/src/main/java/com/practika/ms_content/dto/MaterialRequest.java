package com.practika.ms_content.dto;
import jakarta.validation.constraints.*;
public record MaterialRequest(@NotBlank @Size(max=20) String tipo, String contenidoUrl,
        @Size(max=200) String titulo, @Size(max=1000000) String contenidoTexto) {}
