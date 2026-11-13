package com.practika.ms_academic.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.ObjetivoAprendizaje;

public interface ObjetivoAprendizajeRepository extends JpaRepository<ObjetivoAprendizaje, Integer> {
    java.util.Optional<ObjetivoAprendizaje> findByCodigoIgnoreCase(String codigo);
    List<ObjetivoAprendizaje> findByAsignaturaId(Integer idAsignatura);
    void deleteByAsignaturaId(Integer idAsignatura);
}
