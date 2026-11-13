package com.practika.ms_content.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Material;
public interface MaterialRepository extends JpaRepository<Material, Integer> {
    @org.springframework.data.jpa.repository.Query("select p from Material p where p.evaluacion.tipo = com.practika.ms_content.model.TipoEvaluacion.ACTIVIDAD and coalesce(p.evaluacion.idLegacy,p.evaluacion.idEvaluacion) = :id")
    List<Material> findByIdActividad(@org.springframework.data.repository.query.Param("id") Integer idActividad);
    List<Material> findByIdPreguntaOrderByIdAsc(Integer idPregunta);
    List<Material> findByEvaluacionIdEvaluacionOrderByIdAsc(Integer idEvaluacion);
}
