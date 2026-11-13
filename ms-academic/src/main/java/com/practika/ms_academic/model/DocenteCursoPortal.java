package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "docentes_cursos_portal", uniqueConstraints =
        @UniqueConstraint(name = "uq_docente_curso_portal", columnNames = {"id_curso_portal", "run_profesor"}))
@Getter @Setter @NoArgsConstructor
public class DocenteCursoPortal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_docente_curso")
    private Integer id;
    @Column(name = "id_curso_portal", nullable = false) private Integer idCursoPortal;
    @Column(name = "run_profesor", nullable = false) private Integer runProfesor;
}
