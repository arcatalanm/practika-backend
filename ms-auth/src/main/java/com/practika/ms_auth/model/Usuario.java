package com.practika.ms_auth.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Table (name = "usuarios")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor 
public class Usuario {
    
    @Id 
    @Column(name = "run", nullable = false)
    private Integer run;

    @Column(name = "dv", nullable = false, length = 1)
    private Character dv;

    @Column(name = "nombre1", nullable = false, length = 25)
    private String nombre1; 

    @Column(name = "nombre2", length = 25)
    private String nombre2; 

    @Column(name = "appaterno", nullable = false, length = 50)
    private String appaterno;

    @Column(name = "apmaterno", nullable = false, length = 50)
    private String apmaterno;

    @Column(name = "email", unique = true, length = 100)
    private String email;

    @Column(name = "password", nullable = false, length = 255)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private String password;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_rol", nullable = false)
    private Rol rol;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_seccion")
    private Seccion seccion;

    @Column(name = "img_perfil", length = 255)
    private String imgPerfil;

    /**
     * Borrado lógico: los registros desactivados no se eliminan físicamente.
     * Se deja nullable para que las filas existentes (sin columna) se
     * consideren activas al aplicar ddl-auto=update.
     */
    @Column(name = "activo")
    private Boolean activo = true;

}
