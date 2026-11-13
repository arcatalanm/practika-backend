package com.practika.ms_grading.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name="respuestas", uniqueConstraints = @UniqueConstraint(
        name="uq_respuesta_entrega_pregunta",
        columnNames={"id_entrega", "id_pregunta"}))
@Getter @Setter @NoArgsConstructor
public class Respuesta {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_respuesta") private Integer id;
    @Column(name="run_estudiante", nullable=false) private Integer runEstudiante;
    @Column(name="id_pregunta", nullable=false) private Integer idPregunta;
    @Column(name="id_entrega") private Integer idEntrega;
    @Column(name="numero_intento", nullable=false) private Integer numeroIntento=1;
    @Column(name="fecha_entrega") private LocalDateTime fechaEntrega;
    @Column(name="texto_desarrollo", columnDefinition="TEXT") private String textoDesarrollo;
    @Column(name="puntaje_obtenido", precision=5, scale=2) private BigDecimal puntajeObtenido;
    @ManyToOne(fetch = FetchType.EAGER) @JoinColumn(name="id_estado_revision", nullable=false)
    @JsonIgnore private EstadoRevision estadoRevisionTipo;
    @Transient public String getEstadoRevision() { return estadoRevisionTipo == null ? null : estadoRevisionTipo.getCodigo(); }
    @PrePersist void antesDeGuardar() { if(fechaEntrega==null) fechaEntrega=LocalDateTime.now(); }
}
