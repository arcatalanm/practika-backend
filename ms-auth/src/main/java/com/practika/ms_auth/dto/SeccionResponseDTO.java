package com.practika.ms_auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SeccionResponseDTO {
    private Integer id;
    private String nivelEducativo;
    private Boolean activo;
}
