package com.practika.ms_auth.model;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name="matriculas") @Getter @Setter @NoArgsConstructor
public class Matricula {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_matricula") private Integer id;
    @Column(name="run_estudiante",nullable=false) private Integer runEstudiante;
    @ManyToOne(fetch=FetchType.EAGER) @JoinColumn(name="id_seccion",nullable=false) private Seccion seccion;
    @Column(name="fecha_inicio",nullable=false) private LocalDateTime fechaInicio;
    @Column(name="fecha_fin") private LocalDateTime fechaFin;
    @Column(name="activa",nullable=false) private Boolean activa=true;
    @Column(name="origen",nullable=false,length=20) private String origen="ADMIN";
    @com.fasterxml.jackson.annotation.JsonIgnore
    @Column(name="run_vigente",insertable=false,updatable=false) private Integer runVigente;
}
