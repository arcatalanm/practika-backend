package com.practika.ms_grading.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_grading.model.RespuestaOpcion;
import com.practika.ms_grading.model.RespuestaOpcionId;
public interface RespuestaOpcionRepository extends JpaRepository<RespuestaOpcion,RespuestaOpcionId> {
    List<RespuestaOpcion> findById_IdRespuesta(Integer idRespuesta);
    void deleteById_IdRespuesta(Integer idRespuesta);
}
