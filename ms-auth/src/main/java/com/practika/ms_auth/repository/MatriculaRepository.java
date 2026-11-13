package com.practika.ms_auth.repository;

import java.util.List;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import com.practika.ms_auth.model.*;

public interface MatriculaRepository extends JpaRepository<Matricula,Integer> {
    List<Matricula> findByRunEstudianteOrderByFechaInicioDesc(Integer run);
    List<Matricula> findByRunEstudianteAndActivaTrue(Integer run);
    boolean existsByRunEstudianteAndSeccion_Id(Integer run,Integer idSeccion);
    boolean existsByRunEstudianteAndSeccion_IdAndActivaTrue(Integer run,Integer idSeccion);
    boolean existsBySeccion_Id(Integer idSeccion);
    @Query("select distinct u from Usuario u, Matricula m where u.run=m.runEstudiante and m.seccion.id=:seccion and (:historicas=true or m.activa=true) order by u.appaterno,u.nombre1")
    List<Usuario> participantes(@Param("seccion") Integer seccion,@Param("historicas") boolean historicas);
}
