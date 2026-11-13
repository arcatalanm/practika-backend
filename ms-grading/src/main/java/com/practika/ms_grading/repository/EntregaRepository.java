package com.practika.ms_grading.repository;

import java.util.List;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_grading.model.Entrega;

public interface EntregaRepository extends JpaRepository<Entrega,Integer> {
    List<Entrega> findByRunEstudianteAndIdEvaluacionAsignadaOrderByNumeroIntentoDesc(Integer run,Integer idEvaluacionAsignada);
    List<Entrega> findByIdCursoPortalInOrderByFechaEntregaDesc(List<Integer> cursos);
    List<Entrega> findByRunEstudianteOrderByFechaEntregaDesc(Integer run);
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select e from Entrega e where e.id=:id")
    Optional<Entrega> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);
    List<Entrega> findByRunEstudianteAndIdActividadOrderByNumeroIntentoDesc(Integer run, Integer idActividad);
    List<Entrega> findByRunEstudianteAndIdPruebaOrderByNumeroIntentoDesc(Integer run, Integer idPrueba);
}
