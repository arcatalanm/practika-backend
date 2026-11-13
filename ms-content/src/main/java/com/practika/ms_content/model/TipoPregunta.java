package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "tipos_pregunta") @Getter @Setter @NoArgsConstructor
public class TipoPregunta {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_tipo_pregunta") private Integer id;
    @Column(nullable = false, unique = true, length = 30) private String codigo;
    @Column(nullable = false, length = 60) private String nombre;
    @Column(nullable = false) private Boolean activo = true;
}
