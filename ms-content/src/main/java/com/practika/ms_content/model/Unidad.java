package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "unidades")
@Getter @Setter @NoArgsConstructor
public class Unidad {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_unidad") private Integer id;
    @Column(name = "id_asignatura", nullable = false) private Integer idAsignatura;
    @Column(name = "id_objetivo", nullable = false) private Integer idObjetivo;
    @Column(nullable = false, length = 150) private String titulo;
    @Column(columnDefinition = "TEXT") private String descripcion;
}
