package com.practika.ms_auth.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import com.practika.ms_auth.model.Seccion;

public interface SeccionRepository extends JpaRepository<Seccion, Integer> {
    @Query("select s from Seccion s where s.canonica is null and s.activo = true and s.nivel.activo = true order by s.nivel.codigo")
    List<Seccion> findActivas();
    boolean existsByNivel_IdAndCanonicaIsNull(Integer nivel);
}
