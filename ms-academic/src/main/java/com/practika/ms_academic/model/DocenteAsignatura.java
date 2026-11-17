package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Entity @Table(name = "docentes_asignaturas")
@Getter @Setter @NoArgsConstructor
public class DocenteAsignatura {
    @Id @Column(name = "run_profesor") private Integer runProfesor;
    @Column(name = "id_asignatura", nullable = false) private Integer idAsignatura;
    @Column(name = "ambos_basicos", nullable = false) private Boolean ambosBasicos = false;
}
