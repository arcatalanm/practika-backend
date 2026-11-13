package com.practika.ms_auth.config;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.practika.ms_auth.model.Usuario;
import com.practika.ms_auth.repository.UsuarioRepository;
import com.practika.ms_auth.repository.RolRepository;
import com.practika.ms_auth.util.RunValidator;

@Component
public class AdministradorInicialRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AdministradorInicialRunner.class);

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final String run;
    private final String nombre1;
    private final String appaterno;
    private final String apmaterno;
    private final String email;
    private final String password;

    public AdministradorInicialRunner(
            UsuarioRepository usuarioRepository,
            RolRepository rolRepository,
            PasswordEncoder passwordEncoder,
            @Value("${admin.inicial.run:}") String run,
            @Value("${admin.inicial.nombre1:}") String nombre1,
            @Value("${admin.inicial.appaterno:}") String appaterno,
            @Value("${admin.inicial.apmaterno:}") String apmaterno,
            @Value("${admin.inicial.email:}") String email,
            @Value("${admin.inicial.password:}") String password) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.passwordEncoder = passwordEncoder;
        this.run = normalizar(run);
        this.nombre1 = normalizar(nombre1);
        this.appaterno = normalizar(appaterno);
        this.apmaterno = normalizar(apmaterno);
        this.email = normalizar(email);
        this.password = password == null ? "" : password;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        List<String> values = List.of(run, nombre1, appaterno, apmaterno, email, password);
        boolean configured = values.stream().anyMatch(value -> !value.isBlank());
        if (!configured) {
            log.info("Creación del administrador inicial omitida; configura ADMIN_INICIAL_* para crear la cuenta");
            return;
        }
        if (values.stream().anyMatch(String::isBlank)) {
            throw new IllegalStateException("Para crear el administrador inicial debes configurar todas las variables ADMIN_INICIAL_* requeridas");
        }

        final Integer runNumber;
        try {
            runNumber = Integer.valueOf(run);
        } catch (NumberFormatException ex) {
            throw new IllegalStateException("ADMIN_INICIAL_RUN debe contener solo el RUN numérico", ex);
        }
        if (runNumber <= 0 || runNumber > 99_999_999) {
            throw new IllegalStateException("ADMIN_INICIAL_RUN debe ser un RUN positivo de hasta 8 dígitos");
        }
        if (nombre1.length() > 25 || appaterno.length() > 50 || apmaterno.length() > 50
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$") || email.length() > 100
                || password.length() < 12 || password.length() > 255) {
            throw new IllegalStateException("Revisa los nombres, el correo y la contraseña del administrador inicial (mínimo 12 caracteres)");
        }

        Usuario existente = usuarioRepository.findById(runNumber).orElse(null);
        if (existente != null) {
            if ("ADMIN".equalsIgnoreCase(existente.getRol().getCodigo())) {
                log.info("El administrador inicial con RUN {} ya existe; no se modificó", runNumber);
                return;
            }
            throw new IllegalStateException("Ya existe el RUN configurado para el administrador inicial con otro rol; no se eleva una cuenta existente automáticamente");
        }
        if (usuarioRepository.existsByEmailIgnoreCase(email)) {
            throw new IllegalStateException("El correo configurado para el administrador inicial ya pertenece a otra cuenta");
        }

        Usuario admin = new Usuario();
        admin.setRun(runNumber);
        admin.setDv(RunValidator.calcularDv(runNumber));
        admin.setNombre1(nombre1);
        admin.setAppaterno(appaterno);
        admin.setApmaterno(apmaterno);
        admin.setEmail(email.toLowerCase());
        admin.setPassword(passwordEncoder.encode(password));
        admin.setRol(rolRepository.findByCodigoIgnoreCase("ADMIN")
                .orElseThrow(() -> new IllegalStateException("No existe el rol ADMIN en el catálogo")));
        admin.setActivo(true);
        usuarioRepository.save(admin);
        log.info("Se creó el administrador inicial con RUN {}", runNumber);
    }

    private static String normalizar(String value) {
        return value == null ? "" : value.trim();
    }
}
