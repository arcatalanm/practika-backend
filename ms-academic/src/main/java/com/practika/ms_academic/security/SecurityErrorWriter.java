package com.practika.ms_academic.security;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import org.springframework.http.MediaType;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import tools.jackson.databind.json.JsonMapper;

public final class SecurityErrorWriter {
    private static final JsonMapper JSON = JsonMapper.builder().build();

    private SecurityErrorWriter() {
    }

    public static void write(HttpServletResponse response, HttpServletRequest request,
            int status, String error, String message) throws IOException {
        response.setStatus(status);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        var body = new SecurityError(
                LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS).toString(),
                status, error, message, request.getRequestURI());
        response.getWriter().write(JSON.writeValueAsString(body));
    }

    private record SecurityError(String timestamp, int status, String error, String message, String path) {
    }
}
