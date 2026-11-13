package com.practika.ms_grading.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_grading.model.Respuesta;
public interface RespuestaRepository extends JpaRepository<Respuesta,Integer> {
    List<Respuesta> findByIdEntregaIn(List<Integer> entregas);
    List<Respuesta> findByRunEstudianteAndIdEntregaIsNull(Integer run);
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select r from Respuesta r where r.idEntrega = :id order by r.id")
    List<Respuesta> findForRevision(@org.springframework.data.repository.query.Param("id") Integer id);
    List<Respuesta> findByRunEstudiante(Integer run);
    List<Respuesta> findByIdPregunta(Integer idPregunta);
    List<Respuesta> findByIdEntregaOrderByIdAsc(Integer idEntrega);
    List<Respuesta> findByRunEstudianteAndIdPreguntaIn(Integer run, List<Integer> idsPreguntas);
}
