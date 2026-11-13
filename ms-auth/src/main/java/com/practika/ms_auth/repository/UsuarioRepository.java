package com.practika.ms_auth.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.practika.ms_auth.model.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from Usuario u where u.run=:run")
    Optional<Usuario> findForUpdate(@Param("run") Integer run);

    Optional<Usuario> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndRunNot(String email, Integer run);

    /**
     * Usuarios activos (activo = null se considera activo por compatibilidad
     * con filas previas a la columna).
     */
    @Query("""
            select u from Usuario u
            where (u.activo is null or u.activo = true)
              and (:idSeccion is null or u.seccion.id = :idSeccion)
              and (:rol is null or lower(u.rol.codigo) = lower(:rol))
            order by u.appaterno, u.apmaterno, u.nombre1
            """)
    List<Usuario> buscarActivos(
            @Param("idSeccion") Integer idSeccion,
            @Param("rol") String rol);

    /**
     * Todos los usuarios, incluidos los inactivos (uso administrativo).
     */
    @Query("""
            select u from Usuario u
            where (:idSeccion is null or u.seccion.id = :idSeccion)
              and (:rol is null or lower(u.rol.codigo) = lower(:rol))
            order by u.appaterno, u.apmaterno, u.nombre1
            """)
    List<Usuario> buscarTodos(
            @Param("idSeccion") Integer idSeccion,
            @Param("rol") String rol);
}
