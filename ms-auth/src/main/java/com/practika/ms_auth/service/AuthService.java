package com.practika.ms_auth.service;

import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.practika.ms_auth.dto.LoginRequestDTO;
import com.practika.ms_auth.dto.LoginResponseDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.exception.AccountDisabledException;
import com.practika.ms_auth.exception.InvalidCredentialsException;
import com.practika.ms_auth.exception.ResourceNotFoundException;
import com.practika.ms_auth.mapper.SeccionMapper;
import com.practika.ms_auth.mapper.UsuarioMapper;
import com.practika.ms_auth.model.Usuario;
import com.practika.ms_auth.repository.UsuarioRepository;
import com.practika.ms_auth.security.JwtService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String PATRON_RUN = "\\d{1,8}";

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Transactional
    public LoginResponseDTO login(LoginRequestDTO dto) {
        String identificador = dto.getUsuario().trim();

        Optional<Usuario> encontrado = identificador.matches(PATRON_RUN)
                ? usuarioRepository.findById(Integer.valueOf(identificador))
                : usuarioRepository.findByEmailIgnoreCase(identificador);

        Usuario usuario = encontrado
                .orElseThrow(() -> new InvalidCredentialsException("RUN/correo o contraseña incorrectos"));

        if (Boolean.FALSE.equals(usuario.getActivo())) {
            throw new AccountDisabledException("La cuenta está desactivada. Contacta a un administrador");
        }

        if (!passwordEncoder.matches(dto.getPassword(), usuario.getPassword())) {
            throw new InvalidCredentialsException("RUN/correo o contraseña incorrectos");
        }
        if (passwordEncoder.upgradeEncoding(usuario.getPassword())) {
            usuario.setPassword(passwordEncoder.encode(dto.getPassword()));
            usuarioRepository.save(usuario);
        }

        return LoginResponseDTO.builder()
                .mensaje("Autenticación exitosa")
                .token(jwtService.generarToken(usuario))
                .tipo("Bearer")
                .expiraEn(jwtService.getExpiracionSegundos())
                .run(usuario.getRun())
                .nombreCompleto(UsuarioMapper.nombreCompleto(usuario))
                .email(usuario.getEmail())
                .rol(usuario.getRol().getCodigo())
                .seccion(SeccionMapper.toResponseDTO(usuario.getSeccion()))
                .build();
    }

    @Transactional(readOnly = true)
    public UsuarioResponseDTO perfil(Integer run) {
        Usuario usuario = usuarioRepository.findById(run)
                .orElseThrow(() -> new ResourceNotFoundException("No existe un usuario con el RUN " + run));

        return UsuarioMapper.toResponseDTO(usuario);
    }
}
