package com.practika.ms_content.service;

import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.PreguntaOpcionRequest;

final class PreguntaOpcionesValidator {
    private PreguntaOpcionesValidator() {
    }

    static void validar(String tipo, List<PreguntaOpcionRequest> opciones, Set<Integer> idsExistentes) {
        Set<Integer> idsRecibidos = new HashSet<>();
        for (var opcion : opciones) {
            if (opcion == null || opcion.texto() == null || opcion.texto().isBlank()) {
                throw error("Escribe el texto de cada alternativa");
            }
            if (opcion.esCorrecta() == null) {
                throw error("Indica si cada alternativa es correcta");
            }
            if (opcion.id() != null) {
                if (!idsRecibidos.add(opcion.id())) {
                    throw error("No repitas el id de una alternativa");
                }
                if (!idsExistentes.contains(opcion.id())) {
                    throw error("Una alternativa no pertenece a esta pregunta");
                }
            }
        }
        long correctas = opciones.stream().filter(o -> Boolean.TRUE.equals(o.esCorrecta())).count();
        switch (tipo.toUpperCase(Locale.ROOT)) {
            case "DESARROLLO" -> {
                if (!opciones.isEmpty()) {
                    throw error("Las preguntas de desarrollo no llevan alternativas");
                }
            }
            case "VERDADERO_FALSO" -> {
                if (opciones.size() != 2) {
                    throw error("Verdadero o falso requiere exactamente 2 alternativas");
                }
                if (correctas != 1) {
                    throw error("Marca una sola alternativa correcta");
                }
            }
            case "SELECCION_MULTIPLE" -> {
                if (opciones.size() < 2) {
                    throw error("Agrega al menos 2 alternativas");
                }
                if (correctas == 0) {
                    throw error("Marca al menos una alternativa correcta");
                }
            }
            default -> throw error("Este tipo de pregunta no admite el guardado conjunto de alternativas");
        }
    }

    private static ResponseStatusException error(String mensaje) {
        return new ResponseStatusException(HttpStatus.BAD_REQUEST, mensaje);
    }
}
