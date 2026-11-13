package com.practika.ms_academic.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.PeriodoAcademico;

public interface PeriodoAcademicoRepository extends JpaRepository<PeriodoAcademico, Integer> {
    List<PeriodoAcademico> findByActivoTrueOrderByIdDesc();
    boolean existsByCodigoIgnoreCase(String codigo);
}
