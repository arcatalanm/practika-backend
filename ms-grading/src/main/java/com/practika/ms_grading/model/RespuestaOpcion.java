package com.practika.ms_grading.model;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity @Table(name="respuestas_opciones") @Getter @Setter @NoArgsConstructor
public class RespuestaOpcion {
    @EmbeddedId private RespuestaOpcionId id;
    public RespuestaOpcion(Integer idRespuesta,Integer idOpcion) { this.id=new RespuestaOpcionId(idRespuesta,idOpcion); }
}
