package com.practika.ms_grading.model;

import java.math.BigDecimal;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name="observacion_pedagogicas") @Getter @Setter @NoArgsConstructor
public class ObservacionPedagogica {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_observacion") private Integer id;
    @Column(name="id_curso_portal") private Integer idCursoPortal;
    @Column(name="id_actividad") private Integer idActividad;
    @Column(name="id_prueba") private Integer idPrueba;
    @Column(name="run_estudiante", nullable=false) private Integer runEstudiante;
    @Column(name="texto_retroalimentacion", nullable=false, columnDefinition="TEXT") private String texto;
    @Column(name="porcentaje_logro", nullable=false, precision=5, scale=2) private BigDecimal porcentajeLogro;
}
