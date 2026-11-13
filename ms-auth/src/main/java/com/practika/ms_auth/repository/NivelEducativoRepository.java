package com.practika.ms_auth.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_auth.model.NivelEducativo;

public interface NivelEducativoRepository extends JpaRepository<NivelEducativo, Integer> {
    List<NivelEducativo> findByActivoTrueOrderByIdAsc();
    Optional<NivelEducativo> findByCodigoIgnoreCaseOrNombreIgnoreCase(String codigo, String nombre);
}
