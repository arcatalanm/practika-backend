package com.practika.ms_auth.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.practika.ms_auth.model.Rol;

public interface RolRepository extends JpaRepository<Rol, Integer> {
    Optional<Rol> findByCodigoIgnoreCase(String codigo);
}
