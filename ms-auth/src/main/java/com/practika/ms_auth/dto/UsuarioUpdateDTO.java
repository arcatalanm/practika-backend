package com.practika.ms_auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO para que un ADMIN actualice los datos de un usuario.
 * La contraseña se cambia mediante el endpoint de reseteo.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioUpdateDTO {

    @Size(min = 1, max = 25, message = "El primer nombre debe tener entre 1 y 25 caracteres")
    private String nombre1;

    @Size(max = 25, message = "El segundo nombre no puede superar los 25 caracteres")
    private String nombre2;

    @Size(min = 1, max = 50, message = "El apellido paterno debe tener entre 1 y 50 caracteres")
    private String appaterno;

    @Size(min = 1, max = 50, message = "El apellido materno debe tener entre 1 y 50 caracteres")
    private String apmaterno;

    @Email(message = "El correo electrónico no tiene un formato válido")
    @Size(max = 100, message = "El correo electrónico no puede superar los 100 caracteres")
    private String email;

    @Pattern(regexp = "(?i)ESTUDIANTE|PROFESOR|UTP|ADMIN",
            message = "El rol debe ser ESTUDIANTE, PROFESOR, UTP o ADMIN")
    private String rol;

    private Integer idSeccion;

    @com.fasterxml.jackson.annotation.JsonIgnore
    private boolean seccionDefinida;

    public void setIdSeccion(Integer idSeccion) {
        this.idSeccion = idSeccion;
        this.seccionDefinida = true;
    }

    @Size(max = 255, message = "La imagen de perfil no puede superar los 255 caracteres")
    private String imgPerfil;
}
