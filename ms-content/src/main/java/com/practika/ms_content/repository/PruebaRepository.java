package com.practika.ms_content.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Prueba;
public interface PruebaRepository extends JpaRepository<Prueba, Integer> {
    @Override
    @org.springframework.data.jpa.repository.Query("select e from Prueba e where coalesce(e.idLegacy, e.idEvaluacion) = :id")
    java.util.Optional<Prueba> findById(@org.springframework.data.repository.query.Param("id") Integer id);
    java.util.List<Prueba> findByIdUnidad(Integer idUnidad);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select p from Prueba p where coalesce(p.idLegacy, p.idEvaluacion) = :id")
    java.util.Optional<Prueba> findForUpdate(@org.springframework.data.repository.query.Param("id") Integer id);
}
