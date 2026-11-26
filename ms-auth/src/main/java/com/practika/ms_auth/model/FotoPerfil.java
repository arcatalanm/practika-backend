package com.practika.ms_auth.model;

import jakarta.persistence.*;
import lombok.*;

@Entity @Table(name="fotos_perfil") @Getter @Setter @NoArgsConstructor
public class FotoPerfil {
    @Id @Column(name="run") private Integer run;
    @Column(name="ruta_archivo", nullable=false, length=512) private String rutaArchivo;
}
