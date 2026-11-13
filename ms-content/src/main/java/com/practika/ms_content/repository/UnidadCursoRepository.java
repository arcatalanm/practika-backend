package com.practika.ms_content.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.UnidadCurso;

public interface UnidadCursoRepository extends JpaRepository<UnidadCurso, Integer> {
    @org.springframework.data.jpa.repository.Query("select a.id from UnidadCurso a where a.publicacionInicializada=false order by a.id")
    List<Integer> findIdsPendientesDePublicacion();
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select a from UnidadCurso a where a.id=:id")
    java.util.Optional<UnidadCurso> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);
    boolean existsByIdCurso(Integer idCurso);
    boolean existsByIdUnidad(Integer idUnidad);
    boolean existsByIdUnidadAndIdCurso(Integer idUnidad, Integer idCurso);
    boolean existsByIdCursoAndIdUnidad(Integer idCurso, Integer idUnidad);
    List<UnidadCurso> findByIdCurso(Integer idCurso);
    List<UnidadCurso> findByRunProfesor(Integer runProfesor);
}
