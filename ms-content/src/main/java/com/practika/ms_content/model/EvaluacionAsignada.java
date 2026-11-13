package com.practika.ms_content.model;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name="evaluaciones_asignadas") @Getter @Setter @NoArgsConstructor
public class EvaluacionAsignada {
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name="id_evaluacion", nullable=false)
    @com.fasterxml.jackson.annotation.JsonIgnore private Evaluacion evaluacion;
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_evaluacion_asignada") private Integer id;
    @Column(name="id_asignacion",nullable=false) private Integer idAsignacion;
    @Column(name="version",nullable=false) private Integer version;
    @Column(name="publicada_en",nullable=false) private LocalDateTime publicadaEn;
    @Column(name="run_publicador",nullable=false) private Integer runPublicador;
    @Column(name="activa",nullable=false) private Boolean activa=true;
    @Column(name="huella_origen",nullable=false,length=64) private String huellaOrigen;
    @com.fasterxml.jackson.annotation.JsonIgnore
    @Column(name="contenido_snapshot",nullable=false,columnDefinition="LONGTEXT") private String contenidoSnapshot;

    @Transient @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer getIdEvaluacion() { return evaluacion == null ? null : evaluacion.getIdEvaluacion(); }
    @Transient
    public Integer getIdActividad() {
        return evaluacion != null && evaluacion.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD ? evaluacion.getId() : null;
    }
    @Transient
    public Integer getIdPrueba() {
        return evaluacion != null && evaluacion.getTipoEvaluacion() == TipoEvaluacion.PRUEBA ? evaluacion.getId() : null;
    }
}
