package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name="opciones") @Getter @Setter @NoArgsConstructor
public class Opcion {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_opcion") private Integer id;
    @Column(name="id_pregunta", nullable=false) private Integer idPregunta;
    @Column(name="texto_alternativa", nullable=false, columnDefinition="TEXT") private String texto;
    @Column(name="es_correcta") private Boolean esCorrecta=false;
}
