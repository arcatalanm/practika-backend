package com.practika.ms_content.service;

import java.util.List;
import com.practika.ms_content.dto.CatalogoResponse;
import com.practika.ms_content.model.TipoMaterial;
import com.practika.ms_content.repository.TipoMaterialRepository;
import com.practika.ms_content.repository.TipoPreguntaRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CatalogoServiceTest {
    @Mock TipoMaterialRepository tiposMaterial;
    @Mock TipoPreguntaRepository tiposPregunta;
    @InjectMocks CatalogoService service;

    @Test void devuelveLosTiposDeMaterialDelRepositorioComoRespuesta() {
        var audio = new TipoMaterial();
        audio.setId(1); audio.setCodigo("AUDIO"); audio.setNombre("Audio"); audio.setActivo(true);
        when(tiposMaterial.findByActivoTrueOrderByIdAsc()).thenReturn(List.of(audio));

        var result = service.listarTiposMaterial();

        assertEquals(List.of(new CatalogoResponse(1, "AUDIO", "Audio", true)), result);
        verify(tiposMaterial).findByActivoTrueOrderByIdAsc();
    }
}
