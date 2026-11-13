package com.practika.ms_academic.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.Asignatura;

public interface AsignaturaRepository extends JpaRepository<Asignatura, Integer> {
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select a from Asignatura a order by a.id")
    java.util.List<com.practika.ms_academic.model.Asignatura> bloquearCatalogo();
    boolean existsByNombreIgnoreCase(String nombre);
}
