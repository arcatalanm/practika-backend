package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "periodos_academicos") @Getter @Setter @NoArgsConstructor
public class PeriodoAcademico {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_periodo_academico")
    private Integer id;
    @Column(nullable = false, unique = true, length = 20) private String codigo;
    @Column(nullable = false, length = 60) private String nombre;
    @Column(nullable = false) private Boolean activo = true;
}
