package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity @Table(name="materiales") @Getter @Setter @NoArgsConstructor
public class Material {
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name="id_evaluacion", nullable=true)
    @com.fasterxml.jackson.annotation.JsonIgnore private Evaluacion evaluacion;
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_material") private Integer id;
    @Column(name="id_pregunta") private Integer idPregunta;
    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name="id_tipo_material", nullable=false)
    @JsonIgnore private TipoMaterial tipoMaterial;
    @Column(name="contenido_url", columnDefinition="TEXT") private String contenidoUrl;
    @Column(name="titulo", length=200) private String titulo;
    @Column(name="contenido_texto", columnDefinition="LONGTEXT") private String contenidoTexto;
    @Column(name="activo", nullable=false) private Boolean activo = true;

    @Transient
    public String getTipo() { return tipoMaterial == null ? null : tipoMaterial.getCodigo(); }

    @Transient @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer getIdEvaluacion() { return evaluacion == null ? null : evaluacion.getIdEvaluacion(); }
    @Transient
    public Integer getIdActividad() {
        return evaluacion != null && evaluacion.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD ? evaluacion.getId() : null;
    }
}
