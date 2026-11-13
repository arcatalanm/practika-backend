package com.practika.ms_content.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.TipoPregunta;

public interface TipoPreguntaRepository extends JpaRepository<TipoPregunta, Integer> {
    List<TipoPregunta> findByActivoTrueOrderByIdAsc();
    Optional<TipoPregunta> findByCodigoIgnoreCaseAndActivoTrue(String codigo);
}
