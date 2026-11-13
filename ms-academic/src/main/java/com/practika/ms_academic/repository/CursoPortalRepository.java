package com.practika.ms_academic.repository;

import java.util.List;
import java.util.Collection;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.CursoPortal;

public interface CursoPortalRepository extends JpaRepository<CursoPortal, Integer> {
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select c from CursoPortal c where c.id=:id")
    java.util.Optional<CursoPortal> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);
    java.util.List<CursoPortal> findByIdSeccionInOrderByIdAsc(java.util.List<Integer> secciones);
    List<CursoPortal> findByActivoTrueOrderByIdAsc();
    List<CursoPortal> findByIdSeccionAndActivoTrueOrderByIdAsc(Integer idSeccion);
    List<CursoPortal> findByIdInAndActivoTrueOrderByIdAsc(Collection<Integer> ids);
    List<CursoPortal> findAllByOrderByIdAsc();
    List<CursoPortal> findByIdSeccionAndPeriodoIsNullOrderByIdAsc(Integer idSeccion);
}
