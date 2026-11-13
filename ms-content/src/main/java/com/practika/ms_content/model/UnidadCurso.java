package com.practika.ms_content.model;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "unidades_cursos", uniqueConstraints = @UniqueConstraint(name = "uq_unidad_curso_portal", columnNames = {"id_unidad", "id_curso_portal"}))
@Getter @Setter @NoArgsConstructor
public class UnidadCurso {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_asignacion") private Integer id;
    @Column(name = "id_unidad", nullable = false) private Integer idUnidad;
    @Column(name = "id_curso_portal", nullable = false) private Integer idCurso;
    @Column(name = "run_profesor", nullable = false) private Integer runProfesor;
    @Column(name = "asignado_en", nullable = false) private LocalDateTime asignadoEn = LocalDateTime.now();
    @Column(name = "publicacion_inicializada", nullable = false) private Boolean publicacionInicializada = false;
}
