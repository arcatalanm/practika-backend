package com.practika.ms_academic.service;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_academic.dto.PeriodoAcademicoRequest;
import com.practika.ms_academic.dto.PeriodoAcademicoResponse;
import com.practika.ms_academic.model.PeriodoAcademico;
import com.practika.ms_academic.repository.PeriodoAcademicoRepository;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class PeriodoAcademicoService {
    private final PeriodoAcademicoRepository periodos;

    public List<PeriodoAcademicoResponse> listar() {
        return periodos.findByActivoTrueOrderByIdDesc().stream().map(PeriodoAcademicoResponse::from).toList();
    }

    @Transactional
    public PeriodoAcademicoResponse crear(PeriodoAcademicoRequest dto) {
        if (periodos.existsByCodigoIgnoreCase(dto.codigo().trim())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El período ya existe");
        }
        PeriodoAcademico periodo = new PeriodoAcademico();
        periodo.setCodigo(dto.codigo().trim().toUpperCase(java.util.Locale.ROOT));
        periodo.setNombre(dto.nombre().trim());
        periodo.setActivo(true);
        return PeriodoAcademicoResponse.from(periodos.save(periodo));
    }

    @Transactional
    public PeriodoAcademicoResponse cambiarEstado(Integer id, boolean activo) {
        PeriodoAcademico periodo = periodos.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe el período"));
        periodo.setActivo(activo);
        return PeriodoAcademicoResponse.from(periodos.save(periodo));
    }
}
