package com.practika.ms_content.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_content.model.TipoMaterial;

public interface TipoMaterialRepository extends JpaRepository<TipoMaterial, Integer> {
    List<TipoMaterial> findByActivoTrueOrderByIdAsc();
    Optional<TipoMaterial> findByCodigoIgnoreCaseAndActivoTrue(String codigo);
}
