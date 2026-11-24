package com.practika.ms_academic.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_academic.model.DocenteAsignatura;

public interface DocenteAsignaturaRepository extends JpaRepository<DocenteAsignatura, DocenteAsignatura.Clave> {
    java.util.List<DocenteAsignatura> findByRunProfesor(Integer runProfesor);
    java.util.List<DocenteAsignatura> findByIdAsignaturaAndAmbosBasicosTrue(Integer idAsignatura);
}
