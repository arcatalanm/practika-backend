package com.practika.ms_auth.security;

import java.io.IOException;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import com.practika.ms_auth.security.SecurityErrorWriter;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RestAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
            AccessDeniedException accessDeniedException) throws IOException {

        SecurityErrorWriter.write(response, request,
                HttpStatus.FORBIDDEN.value(), "Forbidden",
                "No tienes permisos para realizar esta operación");
    }
}
