package com.practika.ms_content.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.EvaluacionAsignada;
public interface EvaluacionAsignadaRepository extends JpaRepository<EvaluacionAsignada,Integer> {
    @org.springframework.data.jpa.repository.Query("select count(p) > 0 from EvaluacionAsignada p where p.evaluacion.tipo = com.practika.ms_content.model.TipoEvaluacion.ACTIVIDAD and coalesce(p.evaluacion.idLegacy,p.evaluacion.idEvaluacion) = :id")
    boolean existsByIdActividad(@org.springframework.data.repository.query.Param("id") Integer idActividad);
    @org.springframework.data.jpa.repository.Query("select count(p) > 0 from EvaluacionAsignada p where p.evaluacion.tipo = com.practika.ms_content.model.TipoEvaluacion.PRUEBA and coalesce(p.evaluacion.idLegacy,p.evaluacion.idEvaluacion) = :id")
    boolean existsByIdPrueba(@org.springframework.data.repository.query.Param("id") Integer idPrueba);
    List<EvaluacionAsignada> findByIdAsignacionOrderByVersionDescIdDesc(Integer idAsignacion);
    boolean existsByEvaluacionIdEvaluacion(Integer idEvaluacion);
}
