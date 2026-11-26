package com.practika.ms_content.controller;

import com.practika.ms_content.dto.TiempoResponse;
import com.practika.ms_content.service.TiempoService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TiempoControllerTest {
    @Mock TiempoService service;
    @InjectMocks TiempoController controller;

    @Test void devuelveElTiempoSinHabilitarCacheEnElCliente() {
        var weather = new TiempoResponse("Antonio Varas 666, Providencia", 20, 10, 25,
                0, true, "Despejado", "2026-11-25T12:00", "America/Santiago", "Open-Meteo");
        when(service.obtener()).thenReturn(weather);

        var result = controller.obtener();

        assertEquals(200, result.getStatusCode().value());
        assertEquals(weather, result.getBody());
        assertEquals("no-store", result.getHeaders().getCacheControl());
        verify(service).obtener();
    }
}
