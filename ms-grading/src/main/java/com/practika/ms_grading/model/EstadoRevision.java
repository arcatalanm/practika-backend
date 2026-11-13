package com.practika.ms_grading.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "estados_revision") @Getter @Setter @NoArgsConstructor
public class EstadoRevision {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_estado_revision")
    private Integer id;
    @Column(nullable = false, unique = true, length = 20) private String codigo;
    @Column(nullable = false, length = 50) private String nombre;
}
