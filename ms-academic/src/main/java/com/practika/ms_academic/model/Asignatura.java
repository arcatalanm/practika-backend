package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "asignaturas")
@Getter @Setter @NoArgsConstructor
public class Asignatura {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_asignatura")
    private Integer id;

    @Column(name = "nombre_materia", nullable = false, length = 100)
    private String nombre;

    @Column(name = "activo", nullable = false)
    private Boolean activo = true;
}
