package com.practika.ms_content.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name = "unidad_imagenes") @Getter @Setter @NoArgsConstructor
public class UnidadImagen {
    @Id @Column(name = "id_unidad") private Integer idUnidad;
    @Column(name="ruta_archivo", nullable=false, length=512) private String rutaArchivo;
    @Column(name = "tipo_contenido", nullable = false, length = 50) private String tipoContenido;
}
