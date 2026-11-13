package com.practika.ms_academic.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AsignaturaRequest(@NotBlank @Size(max = 100) String nombre) {}
