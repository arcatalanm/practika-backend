package com.practika.ms_auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponseDTO {

    private String mensaje;
    private String token;
    private String tipo;
    private Long expiraEn;
    private Integer run;
    private String nombreCompleto;
    private String email;
    private String rol;
    private SeccionResponseDTO seccion;
}
