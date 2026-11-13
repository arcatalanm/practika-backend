package com.practika.ms_content.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Pregunta;
public interface PreguntaRepository extends JpaRepository<Pregunta, Integer> {
    @org.springframework.data.jpa.repository.Query("select p from Pregunta p where p.evaluacion.tipo = com.practika.ms_content.model.TipoEvaluacion.ACTIVIDAD and coalesce(p.evaluacion.idLegacy,p.evaluacion.idEvaluacion) = :id")
    List<Pregunta> findByIdActividad(@org.springframework.data.repository.query.Param("id") Integer idActividad);
    @org.springframework.data.jpa.repository.Query("select p from Pregunta p where p.evaluacion.tipo = com.practika.ms_content.model.TipoEvaluacion.PRUEBA and coalesce(p.evaluacion.idLegacy,p.evaluacion.idEvaluacion) = :id")
    List<Pregunta> findByIdPrueba(@org.springframework.data.repository.query.Param("id") Integer idPrueba);
    List<Pregunta> findByEvaluacionIdEvaluacionOrderByIdAsc(Integer idEvaluacion);
}
