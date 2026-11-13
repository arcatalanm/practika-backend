package com.practika.ms_content.model;

import java.math.BigDecimal;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity @Table(name="preguntas") @Getter @Setter @NoArgsConstructor
public class Pregunta {
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name="id_evaluacion", nullable=false)
    @com.fasterxml.jackson.annotation.JsonIgnore private Evaluacion evaluacion;
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_pregunta") private Integer id;
    @Column(name="texto_pregunta", nullable=false, columnDefinition="TEXT") private String texto;
    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name="id_tipo_pregunta", nullable=false)
    @JsonIgnore private TipoPregunta tipoPregunta;
    @Column(name="puntaje_maximo", nullable=false, precision=5, scale=2) private BigDecimal puntajeMaximo=BigDecimal.ONE;

    @Transient
    public String getTipo() { return tipoPregunta == null ? null : tipoPregunta.getCodigo(); }

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
