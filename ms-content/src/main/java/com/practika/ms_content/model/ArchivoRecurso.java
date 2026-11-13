package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name="archivos_recursos") @Getter @Setter @NoArgsConstructor
public class ArchivoRecurso {
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name="id_evaluacion", nullable=true)
    @com.fasterxml.jackson.annotation.JsonIgnore private Evaluacion evaluacion;
    @Id @Column(name="id",length=36) private String id;
    @Column(name="id_pregunta") private Integer idPregunta;
    @Column(name="nombre",nullable=false,length=200) private String nombre;
    @Column(name="tipo_contenido",nullable=false,length=80) private String tipoContenido;
    @Lob @Column(name="contenido",nullable=false,columnDefinition="LONGBLOB") private byte[] contenido;

    @Transient @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer getIdEvaluacion() { return evaluacion == null ? null : evaluacion.getIdEvaluacion(); }
    @Transient
    public Integer getIdActividad() {
        return evaluacion != null && evaluacion.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD ? evaluacion.getId() : null;
    }
}
