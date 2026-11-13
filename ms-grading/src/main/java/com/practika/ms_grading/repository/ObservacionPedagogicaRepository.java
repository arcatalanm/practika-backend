package com.practika.ms_grading.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_grading.model.ObservacionPedagogica;
public interface ObservacionPedagogicaRepository extends JpaRepository<ObservacionPedagogica,Integer> {
    List<ObservacionPedagogica> findByIdCursoPortalIn(List<Integer> cursos);
    List<ObservacionPedagogica> findByRunEstudiante(Integer runEstudiante);
    List<ObservacionPedagogica> findByIdActividad(Integer idActividad);
}
