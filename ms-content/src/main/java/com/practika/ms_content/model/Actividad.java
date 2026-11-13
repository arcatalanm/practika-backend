package com.practika.ms_content.model;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Entity @DiscriminatorValue("ACTIVIDAD") @Getter @Setter @NoArgsConstructor
public class Actividad extends Evaluacion {
    @Override @Transient @com.fasterxml.jackson.annotation.JsonIgnore
    public TipoEvaluacion getTipoEvaluacion() { return TipoEvaluacion.ACTIVIDAD; }
}
