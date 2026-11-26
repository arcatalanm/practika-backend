package com.practika.ms_content.dto;

public record TiempoResponse(String ubicacion, double temperatura, double minima, double maxima,
        int codigo, boolean esDia, String descripcion, String observadoEn, String zonaHoraria, String fuente) { }
