package com.practika.ms_auth.service;

import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.practika.ms_auth.dto.PasswordResetDTO;
import com.practika.ms_auth.dto.UsuarioRequestDTO;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.dto.UsuarioUpdateDTO;
import com.practika.ms_auth.exception.BadRequestException;
import com.practika.ms_auth.exception.ConflictException;
import com.practika.ms_auth.exception.ResourceNotFoundException;
import com.practika.ms_auth.mapper.UsuarioMapper;
import com.practika.ms_auth.model.Seccion;
import com.practika.ms_auth.model.Usuario;
import com.practika.ms_auth.model.Rol;
import com.practika.ms_auth.repository.SeccionRepository;
import com.practika.ms_auth.repository.UsuarioRepository;
import com.practika.ms_auth.repository.RolRepository;
import com.practika.ms_auth.util.RunValidator;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private static final String ROL_POR_DEFECTO = "ESTUDIANTE";

    private final UsuarioRepository usuarioRepository;
    private final SeccionRepository seccionRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final MatriculaService matriculas;

    @Transactional(readOnly = true)
    public List<UsuarioResponseDTO> listar(Integer idSeccion, String rol, boolean incluirInactivos) {
        String rolFiltro = (rol == null || rol.isBlank()) ? null : rol.trim();

        List<Usuario> usuarios = incluirInactivos
                ? usuarioRepository.buscarTodos(idSeccion, rolFiltro)
                : usuarioRepository.buscarActivos(idSeccion, rolFiltro);

        return usuarios.stream()
                .map(UsuarioMapper::toResponseDTO)
                .toList();
    }

    @Transactional(readOnly = true)
    public UsuarioResponseDTO obtenerPorRun(Integer run) {
        return UsuarioMapper.toResponseDTO(buscarUsuario(run));
    }

    /** Registro público: fuerza el rol ESTUDIANTE. */
    @Transactional
    public UsuarioResponseDTO registrar(UsuarioRequestDTO dto) {
        dto.setRol(ROL_POR_DEFECTO);
        dto.setIdSeccion(null);
        return crear(dto);
    }

    @Transactional
    public UsuarioResponseDTO crear(UsuarioRequestDTO dto) {
        Integer run = dto.getRun();
        validarRun(run);
        if (dto.getDv() != null && !RunValidator.esValido(run, dto.getDv())) {
            throw new BadRequestException("El dígito verificador del RUN no es válido");
        }

        String email = normalizarEmail(dto.getEmail());

        if (usuarioRepository.existsById(run)) {
            throw new ConflictException("Ya existe un usuario con el RUN " + run);
        }
        if (email != null && usuarioRepository.existsByEmailIgnoreCase(email)) {
            throw new ConflictException("Ya existe un usuario con el correo " + email);
        }

        Seccion seccion = buscarSeccionOpcional(dto.getIdSeccion());
        Rol rol = buscarRol(normalizarRol(dto.getRol(), ROL_POR_DEFECTO));
        String passwordEncriptada = passwordEncoder.encode(dto.getPassword());

        Usuario usuario = UsuarioMapper.toEntity(dto, seccion, rol, passwordEncriptada);
        usuario.setEmail(email);
        if (seccion != null && !java.util.Set.of("ESTUDIANTE", "PROFESOR").contains(rol.getCodigo()))
            throw new BadRequestException("Solo profesores y estudiantes pertenecen a una sección");

        usuario=usuarioRepository.saveAndFlush(usuario);
        matriculas.sincronizar(usuario);
        return UsuarioMapper.toResponseDTO(usuario);
    }

    /** Actualización de un usuario por parte de un ADMIN. */
    @Transactional
    public UsuarioResponseDTO actualizar(Integer run, UsuarioUpdateDTO dto) {
        Usuario usuario = usuarioRepository.findForUpdate(run)
                .orElseThrow(() -> new ResourceNotFoundException("No existe un usuario con el RUN " + run));

        validarEmailDisponible(dto.getEmail(), run);

        Seccion seccion = buscarSeccionOpcional(dto.getIdSeccion());

        UsuarioMapper.applyAdminChanges(usuario, dto, seccion);
        if (dto.isSeccionDefinida()) usuario.setSeccion(seccion);

        if (dto.getRol() != null) {
            UsuarioMapper.setRol(usuario, buscarRol(normalizarRol(dto.getRol(), null)));
        }

        if (!java.util.Set.of("ESTUDIANTE", "PROFESOR").contains(usuario.getRol().getCodigo())) usuario.setSeccion(null);
        matriculas.sincronizar(usuario);

        return UsuarioMapper.toResponseDTO(usuarioRepository.save(usuario));
    }

    /** Reseteo de contraseña: solo lo usa un ADMIN. */
    @Transactional
    public void restablecerPassword(Integer run, PasswordResetDTO dto) {
        Usuario usuario = buscarUsuario(run);
        usuario.setPassword(passwordEncoder.encode(dto.getPassword()));
        usuarioRepository.save(usuario);
    }

    /**
     * Borrado lógico: el usuario se marca como inactivo.
     */
    @Transactional
    public void eliminar(Integer run) {
        cambiarEstado(run, false);
    }

    @Transactional
    public UsuarioResponseDTO cambiarEstado(Integer run, boolean activo) {
        Usuario usuario = buscarUsuario(run);
        usuario.setActivo(activo);
        return UsuarioMapper.toResponseDTO(usuarioRepository.save(usuario));
    }

    @Transactional
    public UsuarioResponseDTO asignarSeccion(Integer run, Integer idSeccion) {
        Usuario usuario = usuarioRepository.findForUpdate(run)
                .orElseThrow(() -> new ResourceNotFoundException("No existe el usuario"));
        if (!java.util.Set.of("ESTUDIANTE", "PROFESOR").contains(usuario.getRol().getCodigo()))
            throw new BadRequestException("Solo profesores y estudiantes pertenecen a una sección");
        usuario.setSeccion(buscarSeccionOpcional(idSeccion));
        matriculas.sincronizar(usuario);
        return UsuarioMapper.toResponseDTO(usuarioRepository.save(usuario));
    }

    private Usuario buscarUsuario(Integer run) {
        return usuarioRepository.findById(run)
                .orElseThrow(() -> new ResourceNotFoundException("No existe un usuario con el RUN " + run));
    }

    private Seccion buscarSeccionOpcional(Integer idSeccion) {
        if (idSeccion == null) {
            return null;
        }
        Seccion seccion = seccionRepository.findById(idSeccion)
                .orElseThrow(() -> new ResourceNotFoundException("No existe la sección con el ID " + idSeccion)).actual();
        if (!Boolean.TRUE.equals(seccion.getActivo())) throw new BadRequestException("La sección está inactiva");
        return seccion;
    }

    private void validarRun(Integer run) {
        if (run == null || run <= 0 || run > 99_999_999) {
            throw new BadRequestException("El RUN debe ser un número positivo de hasta 8 dígitos");
        }
    }

    private void validarEmailDisponible(String email, Integer run) {
        if (email == null || email.isBlank()) {
            return;
        }
        String emailNormalizado = normalizarEmail(email);
        if (usuarioRepository.existsByEmailIgnoreCaseAndRunNot(emailNormalizado, run)) {
            throw new ConflictException("Ya existe un usuario con el correo " + emailNormalizado);
        }
    }

    private String normalizarRol(String rol, String valorPorDefecto) {
        if (rol == null || rol.isBlank()) {
            return valorPorDefecto;
        }
        String rolNormalizado = rol.trim().toUpperCase();
        if (rolRepository.findByCodigoIgnoreCase(rolNormalizado).isEmpty()) {
            throw new BadRequestException(
                    "Rol inválido: '" + rol + "'. Los roles permitidos son ESTUDIANTE, PROFESOR, UTP y ADMIN");
        }
        return rolNormalizado;
    }

    private Rol buscarRol(String codigo) {
        return rolRepository.findByCodigoIgnoreCase(codigo)
                .orElseThrow(() -> new BadRequestException("Rol no configurado: " + codigo));
    }

    private String normalizarEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        return email.trim().toLowerCase();
    }
}
