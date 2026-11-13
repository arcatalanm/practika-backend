package com.practika.ms_auth.security;

import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;
import com.practika.ms_auth.security.JwtIdentityResolver;
import com.practika.ms_auth.repository.UsuarioRepository;
import io.jsonwebtoken.Claims;

@Component
public class DatabaseJwtIdentityResolver implements JwtIdentityResolver {
    private final UsuarioRepository usuarios;

    public DatabaseJwtIdentityResolver(UsuarioRepository usuarios) {
        this.usuarios = usuarios;
    }

    @Override
    public Optional<Authentication> resolve(Claims claims) {
        Integer run = Integer.valueOf(claims.getSubject());
        return usuarios.findById(run)
                .filter(usuario -> !Boolean.FALSE.equals(usuario.getActivo()))
                .map(usuario -> new UsernamePasswordAuthenticationToken(usuario.getRun(), null,
                        List.of(new SimpleGrantedAuthority(
                                "ROLE_" + usuario.getRol().getCodigo().toUpperCase(Locale.ROOT)))));
    }
}
