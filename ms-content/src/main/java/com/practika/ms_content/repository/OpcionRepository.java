package com.practika.ms_content.repository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.Opcion;
public interface OpcionRepository extends JpaRepository<Opcion, Integer> {
    List<Opcion> findByIdPregunta(Integer idPregunta);
}
