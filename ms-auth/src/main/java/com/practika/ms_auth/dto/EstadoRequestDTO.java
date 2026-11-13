package com.practika.ms_auth.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EstadoRequestDTO {

    @NotNull(message = "El estado activo es obligatorio")
    private Boolean activo;
}
