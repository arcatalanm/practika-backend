package com.practika.ms_content.service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.practika.ms_content.client.AcademicClient;
import com.practika.ms_content.dto.*;
import lombok.RequiredArgsConstructor;

/** Compatibility proxy; the academic service owns the period catalog. */
@Service @RequiredArgsConstructor
public class PeriodoAcademicoService {
    private final AcademicClient academic;
    public List<PeriodoAcademicoResponse> listar() { return CursoPortalService.consultar(academic::listarPeriodos); }
    public PeriodoAcademicoResponse crear(PeriodoAcademicoRequest request) { return CursoPortalService.consultar(() -> academic.crearPeriodo(request)); }
    public PeriodoAcademicoResponse cambiarEstado(Integer id, boolean activo) { return CursoPortalService.consultar(() -> academic.estadoPeriodo(id, activo)); }
}
