package com.practika.ms_grading.dto;

public record EstadoEntregaResponse(int intentosUsados, int maxIntentos,
        boolean hayRespuestasAnteriores, boolean puedeReintentar, EntregaResponse ultimaEntrega) {}
