package com.practika.ms_auth.security;

import java.nio.charset.StandardCharsets;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.practika.ms_auth.exception.BadRequestException;

/** BCrypt has a 72-byte input limit, including multi-byte Unicode characters. */
public class UsuarioPasswordEncoder implements PasswordEncoder {
    private final BCryptPasswordEncoder delegate = new BCryptPasswordEncoder(12);

    @Override public String encode(CharSequence password) {
        if (password == null || password.toString().getBytes(StandardCharsets.UTF_8).length > 72)
            throw new BadRequestException("La contraseña no puede superar 72 bytes UTF-8");
        return delegate.encode(password);
    }
    @Override public boolean matches(CharSequence raw, String encoded) {
        return raw != null && raw.toString().getBytes(StandardCharsets.UTF_8).length <= 72 && delegate.matches(raw, encoded);
    }
    @Override public boolean upgradeEncoding(String encoded) { return delegate.upgradeEncoding(encoded); }
}
