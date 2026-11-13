package com.practika.ms_content.repository;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import com.practika.ms_content.model.*;

public interface EvaluacionRepository extends JpaRepository<Evaluacion, Integer> {
    List<Evaluacion> findByIdUnidadOrderByIdEvaluacionAsc(Integer idUnidad);
    @Query("select e from Evaluacion e where e.tipo = :tipo and coalesce(e.idLegacy,e.idEvaluacion) = :id")
    Optional<Evaluacion> findCompatible(@Param("tipo") TipoEvaluacion tipo, @Param("id") Integer id);
}
