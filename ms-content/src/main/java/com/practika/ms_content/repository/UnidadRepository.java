package com.practika.ms_content.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Unidad;

public interface UnidadRepository extends JpaRepository<Unidad, Integer> {
    java.util.List<Unidad> findByIdAsignatura(Integer idAsignatura);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select u from Unidad u where u.id = :id")
    java.util.Optional<Unidad> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);

    @org.springframework.data.jpa.repository.Query("""
            select u from Unidad u
            where u.idAsignatura = :idAsignatura
              and not exists (
                select a.id from UnidadCurso a
                where a.idCurso = :idCurso and a.idUnidad = u.id
              )
            order by u.id
            """)
    java.util.List<Unidad> findDisponibles(
            @org.springframework.data.repository.query.Param("idAsignatura") Integer idAsignatura,
            @org.springframework.data.repository.query.Param("idCurso") Integer idCurso);
}
