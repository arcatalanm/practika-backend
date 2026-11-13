package com.practika.ms_content.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

@Entity @Table(name = "evaluaciones")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "tipo", length = 16)
@Getter @Setter
public abstract class Evaluacion {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_evaluacion") @JsonIgnore private Integer idEvaluacion;
    @Column(name = "id_legacy", updatable = false) @JsonIgnore private Integer idLegacy;
    @Enumerated(EnumType.STRING)
    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.VARCHAR)
    @Column(name = "tipo", insertable = false, updatable = false, length = 16)
    @JsonIgnore private TipoEvaluacion tipo;
    @Column(name = "id_unidad", nullable = false) private Integer idUnidad;
    @Column(nullable = false, length = 150) private String titulo;
    @Column(name = "estado_activo") private Boolean estadoActivo = true;
    @Column(name = "cantidad_intentos", nullable = false) private Integer cantidadIntentos = 1;

    /** Historical APIs retain their per-type identifier. New APIs use idEvaluacion. */
    @Transient
    public Integer getId() { return idLegacy == null ? idEvaluacion : idLegacy; }
    public void setId(Integer id) { this.idLegacy = id; }

    @Transient @JsonIgnore
    public abstract TipoEvaluacion getTipoEvaluacion();
}
