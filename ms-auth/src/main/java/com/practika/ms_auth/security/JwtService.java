package com.practika.ms_auth.security;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.practika.ms_auth.mapper.UsuarioMapper;
import com.practika.ms_auth.model.Usuario;
import com.practika.ms_auth.security.JwtValidator;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtService {

    private final SecretKey clave;
    private final long expiracionMs;
    private final String emisor;
    private final JwtValidator validator;

    public JwtService(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.expiration-ms:86400000}") long expiracionMs,
            @Value("${jwt.issuer:practika-ms-auth}") String emisor) {

        byte[] bytes = secret == null ? new byte[0] : secret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException(
                    "La propiedad jwt.secret debe tener al menos 32 caracteres para firmar con HS256");
        }

        this.clave = Keys.hmacShaKeyFor(bytes);
        this.expiracionMs = expiracionMs;
        this.emisor = emisor;
        this.validator = new JwtValidator(secret, emisor);
    }

    public String generarToken(Usuario usuario) {
        Instant ahora = Instant.now();

        JwtBuilder builder = Jwts.builder()
                .issuer(emisor)
                .subject(usuario.getRun().toString())
                .claim("rol", usuario.getRol().getCodigo())
                .claim("nombre", UsuarioMapper.nombreCompleto(usuario))
                .issuedAt(Date.from(ahora))
                .expiration(Date.from(ahora.plusMillis(expiracionMs)));

        if (usuario.getEmail() != null) {
            builder.claim("email", usuario.getEmail());
        }
        if (usuario.getSeccion() != null) {
            builder.claim("idSeccion", usuario.getSeccion().getId());
        }

        return builder.signWith(clave).compact();
    }

    public Claims extraerClaims(String token) {
        return validator.claims(token);
    }

    public long getExpiracionSegundos() {
        return expiracionMs / 1000;
    }
}
