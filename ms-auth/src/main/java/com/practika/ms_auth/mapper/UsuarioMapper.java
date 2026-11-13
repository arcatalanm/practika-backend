package com.practika.ms_auth.mapper;

import com.practika.ms_auth.dto.UsuarioRequestDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.dto.UsuarioUpdateDTO;
import com.practika.ms_auth.model.Seccion;
import com.practika.ms_auth.model.Rol;
import com.practika.ms_auth.model.Usuario;
import com.practika.ms_auth.util.RunValidator;

public final class UsuarioMapper {

    private UsuarioMapper() {
    }

    public static Usuario toEntity(UsuarioRequestDTO dto, Seccion seccion, Rol rol, String passwordEncriptada) {
        Usuario usuario = new Usuario();
        usuario.setRun(dto.getRun());
        usuario.setDv(RunValidator.calcularDv(dto.getRun()));
        usuario.setNombre1(dto.getNombre1().trim());
        usuario.setNombre2(limpiarOpcional(dto.getNombre2()));
        usuario.setAppaterno(dto.getAppaterno().trim());
        usuario.setApmaterno(dto.getApmaterno().trim());
        usuario.setEmail(normalizarEmail(dto.getEmail()));
        usuario.setPassword(passwordEncriptada);
        usuario.setRol(rol);
        usuario.setSeccion(seccion);
        usuario.setImgPerfil(limpiarOpcional(dto.getImgPerfil()));
        usuario.setActivo(true);
        return usuario;
    }

    public static void applyAdminChanges(Usuario usuario, UsuarioUpdateDTO dto, Seccion seccion) {
        aplicarDatosComunes(usuario, dto.getNombre1(), dto.getNombre2(),
                dto.getAppaterno(), dto.getApmaterno(), dto.getEmail(), dto.getImgPerfil(), seccion);

    }

    public static void setRol(Usuario usuario, Rol rol) {
        usuario.setRol(rol);
    }

    private static void aplicarDatosComunes(Usuario usuario, String nombre1,
            String nombre2, String appaterno, String apmaterno, String email,
            String imgPerfil, Seccion seccion) {

        usuario.setDv(RunValidator.calcularDv(usuario.getRun()));
        if (nombre1 != null) {
            usuario.setNombre1(nombre1.trim());
        }
        if (nombre2 != null) {
            usuario.setNombre2(limpiarOpcional(nombre2));
        }
        if (appaterno != null) {
            usuario.setAppaterno(appaterno.trim());
        }
        if (apmaterno != null) {
            usuario.setApmaterno(apmaterno.trim());
        }
        if (email != null) {
            usuario.setEmail(normalizarEmail(email));
        }
        if (imgPerfil != null) {
            usuario.setImgPerfil(limpiarOpcional(imgPerfil));
        }
        if (seccion != null) {
            usuario.setSeccion(seccion);
        }
    }

    public static UsuarioResponseDTO toResponseDTO(Usuario usuario) {
        if (usuario == null) {
            return null;
        }
        return UsuarioResponseDTO.builder()
                .run(usuario.getRun())
                .dv(usuario.getDv())
                .nombre1(usuario.getNombre1())
                .nombre2(usuario.getNombre2())
                .appaterno(usuario.getAppaterno())
                .apmaterno(usuario.getApmaterno())
                .nombreCompleto(nombreCompleto(usuario))
                .email(usuario.getEmail())
                .rol(usuario.getRol().getCodigo())
                .seccion(SeccionMapper.toResponseDTO(usuario.getSeccion()))
                .imgPerfil(usuario.getImgPerfil())
                .activo(!Boolean.FALSE.equals(usuario.getActivo()))
                .build();
    }

    public static String nombreCompleto(Usuario usuario) {
        StringBuilder nombre = new StringBuilder(usuario.getNombre1().trim());
        if (usuario.getNombre2() != null && !usuario.getNombre2().isBlank()) {
            nombre.append(' ').append(usuario.getNombre2().trim());
        }
        nombre.append(' ').append(usuario.getAppaterno().trim());
        nombre.append(' ').append(usuario.getApmaterno().trim());
        return nombre.toString();
    }

    private static String normalizarEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        return email.trim().toLowerCase();
    }

    private static String limpiarOpcional(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim();
    }
}
