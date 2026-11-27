package com.practika.ms_content.service;

import java.util.List;
import java.util.Set;
import com.practika.ms_content.dto.PreguntaOpcionRequest;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;
import static org.junit.jupiter.api.Assertions.*;

class PreguntaOpcionesValidatorTest {
    private final List<PreguntaOpcionRequest> opciones = List.of(
            new PreguntaOpcionRequest(1, "Primera", true),
            new PreguntaOpcionRequest(2, "Segunda", false));

    @Test void permiteEditarSeleccionUnicaConAlternativasExistentes() {
        assertDoesNotThrow(() -> PreguntaOpcionesValidator.validar("SELECCION_UNICA", opciones, Set.of(1, 2)));
    }

    @Test void permiteCrearSeleccionUnicaConAlternativasNuevas() {
        assertDoesNotThrow(() -> PreguntaOpcionesValidator.validar("SELECCION_UNICA", List.of(
                new PreguntaOpcionRequest(null, "Primera", false),
                new PreguntaOpcionRequest(null, "Segunda", true)), Set.of()));
    }

    @Test void seleccionUnicaRequiereExactamenteUnaCorrecta() {
        for (boolean correcta : List.of(true, false)) {
            var error = assertThrows(ResponseStatusException.class,
                    () -> PreguntaOpcionesValidator.validar("SELECCION_UNICA", List.of(
                            new PreguntaOpcionRequest(null, "Primera", correcta),
                            new PreguntaOpcionRequest(null, "Segunda", correcta)), Set.of()));
            assertEquals(400, error.getStatusCode().value());
        }
    }

    @Test void seleccionUnicaRequiereAlMenosDosAlternativas() {
        assertThrows(ResponseStatusException.class, () -> PreguntaOpcionesValidator.validar(
                "SELECCION_UNICA", List.of(new PreguntaOpcionRequest(null, "Primera", true)), Set.of()));
    }

    @Test void rechazaAlternativasDeOtraPregunta() {
        assertThrows(ResponseStatusException.class,
                () -> PreguntaOpcionesValidator.validar("SELECCION_UNICA", opciones, Set.of(1)));
    }

    @Test void mantieneLosOtrosTiposDePregunta() {
        assertDoesNotThrow(() -> PreguntaOpcionesValidator.validar("VERDADERO_FALSO", opciones, Set.of(1, 2)));
        assertDoesNotThrow(() -> PreguntaOpcionesValidator.validar("DESARROLLO", List.of(), Set.of()));
        assertDoesNotThrow(() -> PreguntaOpcionesValidator.validar("SELECCION_MULTIPLE", List.of(
                new PreguntaOpcionRequest(null, "Primera", true),
                new PreguntaOpcionRequest(null, "Segunda", true)), Set.of()));
    }
}
