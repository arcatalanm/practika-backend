package com.practika.ms_auth.security;

import java.io.IOException;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import com.practika.ms_auth.security.SecurityErrorWriter;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException authException) throws IOException {

        String mensaje = "Inicia sesión para continuar.";

        SecurityErrorWriter.write(response, request,
                HttpStatus.UNAUTHORIZED.value(), "Unauthorized", mensaje);
    }
}
