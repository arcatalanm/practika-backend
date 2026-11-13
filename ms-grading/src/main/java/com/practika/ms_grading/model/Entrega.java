package com.practika.ms_grading.model;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name="entregas", uniqueConstraints={
    @UniqueConstraint(name="uq_entrega_evaluacion_intento", columnNames={"run_estudiante","id_evaluacion_asignada","numero_intento"})
}) @Getter @Setter @NoArgsConstructor
public class Entrega {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_entrega") private Integer id;
    @Column(name="run_estudiante", nullable=false) private Integer runEstudiante;
    @Column(name="id_actividad") private Integer idActividad;
    @Column(name="id_prueba") private Integer idPrueba;
    @Column(name="numero_intento", nullable=false) private Integer numeroIntento;
    @Column(name="fecha_entrega", nullable=false) private LocalDateTime fechaEntrega;
    @Column(name="estado", nullable=false, length=20) private String estado = "EN_REVISION";
    @Column(name="permite_reintento", nullable=false) private Boolean permiteReintento = false;
    @Column(name="fecha_revision") private LocalDateTime fechaRevision;
    @Column(name="comentario", columnDefinition="TEXT") private String comentario;
    @Column(name="id_evaluacion_asignada") private Integer idEvaluacionAsignada;
    @Column(name="id_curso_portal") private Integer idCursoPortal;
    @Column(name="id_periodo_academico") private Integer idPeriodoAcademico;
    @Column(name="id_seccion") private Integer idSeccion;
    @com.fasterxml.jackson.annotation.JsonIgnore
    @Column(name="snapshot_evaluacion",columnDefinition="LONGTEXT") private String snapshotEvaluacion;
    @Column(name="snapshot_reconstruido",nullable=false) private Boolean snapshotReconstruido=false;
    @PrePersist void antesDeGuardar() { if (fechaEntrega == null) fechaEntrega = LocalDateTime.now(); }
}
