package com.practika.ms_grading.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_grading.model.EstadoRevision;

public interface EstadoRevisionRepository extends JpaRepository<EstadoRevision, Integer> {
    List<EstadoRevision> findAllByOrderByIdAsc();
    Optional<EstadoRevision> findByCodigoIgnoreCase(String codigo);
}
