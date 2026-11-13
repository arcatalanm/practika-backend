package com.practika.ms_academic.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "objetivo_aprendizajes")
@Getter @Setter @NoArgsConstructor
public class ObjetivoAprendizaje {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_aprendizaje")
    private Integer id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_asignatura", nullable = false)
    private Asignatura asignatura;

    @Column(name = "descripcion_objetivo", nullable = false, columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "codigo", nullable = false, unique = true, length = 40)
    private String codigo;
}
