package com.practika.ms_content.service;

import com.practika.ms_content.dto.UnidadRequest;
import com.practika.ms_content.model.Unidad;
import com.practika.ms_content.repository.UnidadRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UnidadServiceTest {
    @Mock UnidadRepository unidades;
    @Mock CrossServiceValidator validator;
    @InjectMocks UnidadService service;

    @Test void creaLaUnidadConElTituloLimpioYLasReferenciasIndicadas() {
        when(unidades.save(any(Unidad.class))).thenAnswer(invocation -> {
            Unidad unidad = invocation.getArgument(0);
            unidad.setId(10);
            return unidad;
        });

        var result = service.crear(new UnidadRequest(1, 2, "  Mi unidad  ", "Descripción"));

        assertEquals(10, result.id());
        assertEquals("Mi unidad", result.titulo());
        assertEquals(1, result.idAsignatura());
        assertEquals(2, result.idObjetivo());
        verify(validator).validarUnidad(1, 2);
        verify(unidades).save(any(Unidad.class));
    }
}
