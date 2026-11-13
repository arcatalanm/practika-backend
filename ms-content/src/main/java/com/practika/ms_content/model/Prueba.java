package com.practika.ms_content.model;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Entity @DiscriminatorValue("PRUEBA") @Getter @Setter @NoArgsConstructor
public class Prueba extends Evaluacion {
    @Column(name="fecha_aplicacion") private java.time.LocalDateTime fechaAplicacion;
    @Override @Transient @com.fasterxml.jackson.annotation.JsonIgnore
    public TipoEvaluacion getTipoEvaluacion() { return TipoEvaluacion.PRUEBA; }
}
