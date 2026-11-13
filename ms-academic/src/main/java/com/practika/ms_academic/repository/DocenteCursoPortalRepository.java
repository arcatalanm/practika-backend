package com.practika.ms_academic.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.DocenteCursoPortal;

public interface DocenteCursoPortalRepository extends JpaRepository<DocenteCursoPortal, Integer> {
    List<DocenteCursoPortal> findByRunProfesor(Integer runProfesor);
    List<DocenteCursoPortal> findByRunProfesorAndIdCursoPortalIn(Integer runProfesor, List<Integer> ids);
    List<DocenteCursoPortal> findByIdCursoPortal(Integer idCursoPortal);
    boolean existsByIdCursoPortalAndRunProfesor(Integer idCursoPortal, Integer runProfesor);
    void deleteByIdCursoPortalAndRunProfesor(Integer idCursoPortal, Integer runProfesor);
}
