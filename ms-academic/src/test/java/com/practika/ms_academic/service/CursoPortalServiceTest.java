package com.practika.ms_academic.service;

import java.util.Optional;
import com.practika.ms_academic.repository.CursoPortalRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CursoPortalServiceTest {
    @Mock CursoPortalRepository cursos;
    @InjectMocks CursoPortalService service;

    @Test void rechazaActivarUnCursoQueNoExiste() {
        when(cursos.findById(999)).thenReturn(Optional.empty());

        var error = assertThrows(ResponseStatusException.class, () -> service.estado(999, true));

        assertEquals(404, error.getStatusCode().value());
        verify(cursos, never()).save(any());
    }
}
