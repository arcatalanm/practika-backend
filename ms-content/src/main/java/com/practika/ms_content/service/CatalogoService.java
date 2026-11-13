package com.practika.ms_content.service;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.practika.ms_content.dto.CatalogoResponse;
import com.practika.ms_content.repository.TipoMaterialRepository;
import com.practika.ms_content.repository.TipoPreguntaRepository;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class CatalogoService {
    private final TipoMaterialRepository tiposMaterial;
    private final TipoPreguntaRepository tiposPregunta;

    public List<CatalogoResponse> listarTiposMaterial() {
        return tiposMaterial.findByActivoTrueOrderByIdAsc().stream().map(CatalogoResponse::from).toList();
    }

    public List<CatalogoResponse> listarTiposPregunta() {
        return tiposPregunta.findByActivoTrueOrderByIdAsc().stream().map(CatalogoResponse::from).toList();
    }
}
