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
public class UsuarioResponseDTO {

    private Integer run;
    private Character dv;
    private String nombre1;
    private String nombre2;
    private String appaterno;
    private String apmaterno;
    private String nombreCompleto;
    private String email;
    private String rol;
    private SeccionResponseDTO seccion;
    private String imgPerfil;
    private Boolean activo;
}
