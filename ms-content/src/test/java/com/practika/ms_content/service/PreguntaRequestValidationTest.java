package com.practika.ms_content.service;

import java.math.BigDecimal;
import java.util.List;
import com.practika.ms_content.dto.*;
import jakarta.validation.Validation;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PreguntaRequestValidationTest {
    @Test void validaElContenidoDeLasAlternativasEnAmbosContratos() {
        try (var factory = Validation.buildDefaultValidatorFactory()) {
            var validator = factory.getValidator();
            var opciones = List.of(new PreguntaOpcionRequest(-1, "", null));
            var canonical = new PreguntaEnEvaluacionRequest("Pregunta", "SELECCION_UNICA", BigDecimal.ONE, opciones);
            var legacy = new PreguntaRequest(1, null, "Pregunta", "SELECCION_UNICA", BigDecimal.ONE, opciones);
            for (var request : List.of(canonical, legacy)) {
                var errores = validator.validate(request);
                assertEquals(3, errores.size());
                assertTrue(errores.stream().allMatch(e -> e.getPropertyPath().toString().startsWith("opciones[0]")));
            }
        }
    }
}
