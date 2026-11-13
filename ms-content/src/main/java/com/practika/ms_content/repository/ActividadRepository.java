package com.practika.ms_content.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Actividad;
public interface ActividadRepository extends JpaRepository<Actividad, Integer> {
    @Override
    @org.springframework.data.jpa.repository.Query("select e from Actividad e where coalesce(e.idLegacy, e.idEvaluacion) = :id")
    java.util.Optional<Actividad> findById(@org.springframework.data.repository.query.Param("id") Integer id);
    java.util.List<Actividad> findByIdUnidad(Integer idUnidad);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select a from Actividad a where coalesce(a.idLegacy, a.idEvaluacion) = :id")
    java.util.Optional<Actividad> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);
}
