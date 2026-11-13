package com.practika.ms_auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioRequestDTO {

    @NotNull(message = "El RUN es obligatorio")
    @Positive(message = "El RUN debe ser un número positivo")
    @Max(value = 99_999_999, message = "El RUN no puede superar los 8 dígitos")
    private Integer run;
    private Character dv;

    @NotBlank(message = "El primer nombre es obligatorio")
    @Size(max = 25, message = "El primer nombre no puede superar los 25 caracteres")
    private String nombre1;

    @Size(max = 25, message = "El segundo nombre no puede superar los 25 caracteres")
    private String nombre2;

    @NotBlank(message = "El apellido paterno es obligatorio")
    @Size(max = 50, message = "El apellido paterno no puede superar los 50 caracteres")
    private String appaterno;

    @NotBlank(message = "El apellido materno es obligatorio")
    @Size(max = 50, message = "El apellido materno no puede superar los 50 caracteres")
    private String apmaterno;

    @Email(message = "El correo electrónico no tiene un formato válido")
    @Size(max = 100, message = "El correo electrónico no puede superar los 100 caracteres")
    private String email;

    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 8, max = 255, message = "La contraseña debe tener entre 8 y 255 caracteres")
    private String password;

    @Pattern(regexp = "(?i)ESTUDIANTE|PROFESOR|UTP|ADMIN",
            message = "El rol debe ser ESTUDIANTE, PROFESOR, UTP o ADMIN")
    private String rol;

    private Integer idSeccion;

    @Size(max = 255, message = "La imagen de perfil no puede superar los 255 caracteres")
    private String imgPerfil;
}
