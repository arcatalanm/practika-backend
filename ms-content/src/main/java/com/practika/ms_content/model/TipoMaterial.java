package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "tipos_material") @Getter @Setter @NoArgsConstructor
public class TipoMaterial {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_tipo_material") private Integer id;
    @Column(nullable = false, unique = true, length = 20) private String codigo;
    @Column(nullable = false, length = 50) private String nombre;
    @Column(nullable = false) private Boolean activo = true;
}
