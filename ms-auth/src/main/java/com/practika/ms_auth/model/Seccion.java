package com.practika.ms_auth.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name = "secciones")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Seccion {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Column(name = "id_seccion")
    private Integer id;

    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name = "id_nivel_educativo", nullable = false)
    private NivelEducativo nivel;

    // Retired rows remain as aliases so existing deliveries retain their original IDs.
    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name = "id_seccion_canonica")
    private Seccion canonica;

    public Seccion actual() { return canonica == null ? this : canonica; }

    @Column(name = "activo", nullable = false)
    private Boolean activo = true;
}
