package com.practika.ms_content.model;
import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name="archivos_evaluacion") @Getter @Setter @NoArgsConstructor
public class ArchivoEvaluacion {
    @Id @Column(name="id",length=36) private String id;
    @Column(name="id_evaluacion_asignada",nullable=false) private Integer idEvaluacionAsignada;
    @Column(name="nombre",nullable=false,length=200) private String nombre;
    @Column(name="tipo_contenido",nullable=false,length=80) private String tipoContenido;
    @Lob @Column(name="contenido",nullable=false,columnDefinition="LONGBLOB") private byte[] contenido;
}
