package com.practika.ms_auth.service;

import java.util.Optional;
import com.practika.ms_auth.dto.SeccionRequestDTO;
import com.practika.ms_auth.exception.BadRequestException;
import com.practika.ms_auth.model.NivelEducativo;
import com.practika.ms_auth.repository.NivelEducativoRepository;
import com.practika.ms_auth.repository.SeccionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SeccionServiceTest {
    @Mock SeccionRepository secciones;
    @Mock NivelEducativoRepository niveles;
    @InjectMocks SeccionService service;

    @Test void rechazaCrearUnaSeccionDeTerceroBasico() {
        var tercero = new NivelEducativo();
        tercero.setCodigo("3° Básico");
        tercero.setActivo(true);
        when(niveles.findByCodigoIgnoreCaseOrNombreIgnoreCase("3° Básico", "3° Básico"))
                .thenReturn(Optional.of(tercero));

        assertThrows(BadRequestException.class, () -> service.crear(new SeccionRequestDTO("3° Básico")));

        verify(secciones, never()).save(any());
    }
}
