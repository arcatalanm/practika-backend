package com.practika.ms_auth.exception;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import com.practika.ms_auth.dto.ErrorResponseDTO;

import jakarta.servlet.http.HttpServletRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(org.springframework.web.multipart.MaxUploadSizeExceededException.class)
    public ResponseEntity<ErrorResponseDTO> imagenDemasiadoGrande(Exception ex, HttpServletRequest request) {
        return construir(HttpStatus.PAYLOAD_TOO_LARGE, "La imagen no puede superar 5 MB", request, null);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponseDTO> manejarNoEncontrado(
            ResourceNotFoundException ex, HttpServletRequest request) {
        return construir(HttpStatus.NOT_FOUND, ex.getMessage(), request, null);
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorResponseDTO> manejarConflicto(
            ConflictException ex, HttpServletRequest request) {
        return construir(HttpStatus.CONFLICT, ex.getMessage(), request, null);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponseDTO> manejarIntegridad(
            DataIntegrityViolationException ex, HttpServletRequest request) {
        log.warn("Violación de integridad de datos: {}", ex.getMostSpecificCause().getMessage());
        return construir(HttpStatus.CONFLICT,
                "La operación viola una restricción de la base de datos. " +
                        "Verifique que el registro no esté duplicado o en uso.",
                request, null);
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<ErrorResponseDTO> manejarCredenciales(
            InvalidCredentialsException ex, HttpServletRequest request) {
        return construir(HttpStatus.UNAUTHORIZED, ex.getMessage(), request, null);
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponseDTO> manejarSolicitudInvalida(
            BadRequestException ex, HttpServletRequest request) {
        return construir(HttpStatus.BAD_REQUEST, ex.getMessage(), request, null);
    }

    @ExceptionHandler(AccountDisabledException.class)
    public ResponseEntity<ErrorResponseDTO> manejarCuentaDesactivada(
            AccountDisabledException ex, HttpServletRequest request) {
        return construir(HttpStatus.FORBIDDEN, ex.getMessage(), request, null);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponseDTO> manejarAccesoDenegado(
            AccessDeniedException ex, HttpServletRequest request) {
        return construir(HttpStatus.FORBIDDEN,
                "No tienes permisos para realizar esta operación", request, null);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponseDTO> manejarValidacion(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        Map<String, String> detalles = new LinkedHashMap<>();
        ex.getBindingResult().getFieldErrors()
                .forEach(error -> detalles.putIfAbsent(error.getField(), error.getDefaultMessage()));

        return construir(HttpStatus.BAD_REQUEST,
                "Los datos enviados no son válidos", request, detalles);
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<ErrorResponseDTO> manejarFormatoInvalido(
            Exception ex, HttpServletRequest request) {
        return construir(HttpStatus.BAD_REQUEST,
                "El cuerpo o alguno de los parámetros de la solicitud tiene un formato inválido",
                request, null);
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ErrorResponseDTO> manejarRecursoNoEncontrado(
            NoResourceFoundException ex, HttpServletRequest request) {
        return construir(HttpStatus.NOT_FOUND, "El recurso solicitado no existe", request, null);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponseDTO> manejarMetodoNoSoportado(
            HttpRequestMethodNotSupportedException ex, HttpServletRequest request) {
        return construir(HttpStatus.METHOD_NOT_ALLOWED,
                "El método HTTP " + ex.getMethod() + " no está soportado para esta ruta",
                request, null);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponseDTO> manejarErrorGeneral(
            Exception ex, HttpServletRequest request) {
        log.error("Error no controlado en la solicitud {}", request.getRequestURI(), ex);
        return construir(HttpStatus.INTERNAL_SERVER_ERROR,
                "Ocurrió un error interno al procesar la solicitud", request, null);
    }

    private ResponseEntity<ErrorResponseDTO> construir(
            HttpStatus status, String mensaje, HttpServletRequest request, Map<String, String> detalles) {

        ErrorResponseDTO error = ErrorResponseDTO.builder()
                .timestamp(LocalDateTime.now())
                .status(status.value())
                .error(status.getReasonPhrase())
                .message(mensaje)
                .path(request.getRequestURI())
                .detalles(detalles)
                .build();

        return ResponseEntity.status(status).body(error);
    }
}
