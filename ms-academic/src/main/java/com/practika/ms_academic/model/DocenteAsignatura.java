package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;

@Entity @Table(name = "docentes_asignaturas")
@IdClass(DocenteAsignatura.Clave.class)
@Getter @Setter @NoArgsConstructor
public class DocenteAsignatura {
    @Id @Column(name = "run_profesor") private Integer runProfesor;
    @Id @Column(name = "id_asignatura", nullable = false) private Integer idAsignatura;
    @Column(name = "ambos_basicos", nullable = false) private Boolean ambosBasicos = false;

    @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
    public static class Clave implements java.io.Serializable {
        private Integer runProfesor;
        private Integer idAsignatura;
    }
}
