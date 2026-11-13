package com.practika.ms_grading.model;

import java.io.Serializable;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Embeddable @Getter @Setter @NoArgsConstructor @EqualsAndHashCode
public class RespuestaOpcionId implements Serializable {
    @Column(name="id_respuesta") private Integer idRespuesta;
    @Column(name="id_opcion") private Integer idOpcion;
    public RespuestaOpcionId(Integer idRespuesta,Integer idOpcion) { this.idRespuesta=idRespuesta; this.idOpcion=idOpcion; }
}
