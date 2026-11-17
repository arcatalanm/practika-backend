package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "unidad_imagenes") @Getter @Setter @NoArgsConstructor
public class UnidadImagen {
    @Id @Column(name = "id_unidad") private Integer idUnidad;
    @Lob @Column(name = "contenido", nullable = false, columnDefinition = "MEDIUMBLOB") private byte[] contenido;
    @Column(name = "tipo_contenido", nullable = false, length = 50) private String tipoContenido;
}
