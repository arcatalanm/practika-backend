package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "cursos_portal") @Getter @Setter @NoArgsConstructor
public class CursoPortal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_curso_portal")
    private Integer id;
    @Column(name = "id_seccion", nullable = false) private Integer idSeccion;
    @Column(name = "id_asignatura") private Integer idAsignatura;
    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name = "id_periodo_academico")
    private PeriodoAcademico periodo;
    @Column(nullable = false, length = 120) private String nombre;
    @Column(columnDefinition = "TEXT") private String descripcion;
    @Column(nullable = false) private Boolean activo = true;
}
