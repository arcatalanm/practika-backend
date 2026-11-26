package com.practika.ms_content.service;

import java.time.*;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.practika.ms_content.dto.TiempoResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

public class TiempoService {
    private static final ZoneId ZONE = ZoneId.of("America/Santiago");
    private final RestClient client;
    private final String ubicacion;
    private final double latitude;
    private final double longitude;
    private final Clock clock;
    private TiempoResponse cached;
    private Instant expiresAt = Instant.MIN;
    private Instant retryAt = Instant.MIN;

    public TiempoService(RestClient client, String ubicacion, double latitude, double longitude, Clock clock) {
        if (!Double.isFinite(latitude) || Math.abs(latitude) > 90 || !Double.isFinite(longitude) || Math.abs(longitude) > 180)
            throw new IllegalArgumentException("Coordenadas del tiempo no validas");
        this.client = client; this.ubicacion = ubicacion; this.latitude = latitude; this.longitude = longitude; this.clock = clock;
    }

    public synchronized TiempoResponse obtener() {
        var now = clock.instant();
        var today = now.atZone(ZONE).toLocalDate();
        if (cached != null && now.isBefore(expiresAt) && cached.observadoEn().startsWith(today.toString())) return cached;
        if (now.isBefore(retryAt)) throw unavailable(null);
        try {
            var data = client.get().uri(uri -> uri.path("/v1/forecast")
                    .queryParam("latitude", latitude).queryParam("longitude", longitude)
                    .queryParam("current", "temperature_2m,weather_code,is_day")
                    .queryParam("daily", "temperature_2m_min,temperature_2m_max")
                    .queryParam("temperature_unit", "celsius").queryParam("timezone", ZONE.getId())
                    .queryParam("forecast_days", 1).build()).retrieve().body(ProviderResponse.class);
            var result = convertir(data, today);
            cached = result;
            expiresAt = clock.instant().plus(Duration.ofMinutes(10));
            retryAt = Instant.MIN;
            return result;
        } catch (RuntimeException ex) {
            retryAt = clock.instant().plusSeconds(30);
            throw unavailable(ex);
        }
    }

    private TiempoResponse convertir(ProviderResponse data, LocalDate today) {
        if (data == null || data.current() == null || data.daily() == null) throw new IllegalArgumentException("Respuesta meteorologica incompleta");
        var current = data.current(); var daily = data.daily();
        if (current.time() == null || !LocalDateTime.parse(current.time()).toLocalDate().equals(today)
                || current.weather_code() == null || current.is_day() == null || (current.is_day() != 0 && current.is_day() != 1)
                || daily.time() == null || daily.time().size() != 1 || !today.toString().equals(daily.time().getFirst())
                || daily.temperature_2m_min() == null || daily.temperature_2m_min().size() != 1
                || daily.temperature_2m_max() == null || daily.temperature_2m_max().size() != 1)
            throw new IllegalArgumentException("Respuesta meteorologica invalida");
        double temperature = numero(current.temperature_2m());
        double min = numero(daily.temperature_2m_min().getFirst());
        double max = numero(daily.temperature_2m_max().getFirst());
        if (min > max) throw new IllegalArgumentException("Rango meteorologico invalido");
        return new TiempoResponse(ubicacion, temperature, min, max, current.weather_code(), current.is_day() == 1,
                descripcion(current.weather_code(), current.is_day() == 1), current.time(), ZONE.getId(), "Open-Meteo");
    }

    private double numero(Double value) {
        if (value == null || !Double.isFinite(value)) throw new IllegalArgumentException("Temperatura ausente");
        return value;
    }

    private String descripcion(int code, boolean day) {
        return switch (code) {
            case 0 -> day ? "Despejado" : "Noche despejada";
            case 1 -> "Mayormente despejado";
            case 2 -> "Parcialmente nublado";
            case 3 -> "Nublado";
            case 45, 48 -> "Niebla";
            case 51, 53, 55 -> "Llovizna";
            case 56, 57 -> "Llovizna helada";
            case 61, 63, 65 -> "Lluvia";
            case 66, 67 -> "Lluvia helada";
            case 71, 73, 75, 77 -> "Nieve";
            case 80, 81, 82 -> "Chubascos";
            case 85, 86 -> "Chubascos de nieve";
            case 95, 96, 99 -> "Tormenta";
            default -> "Condiciones variables";
        };
    }

    private ResponseStatusException unavailable(Throwable cause) {
        return new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "El tiempo no esta disponible. Intenta nuevamente.", cause);
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ProviderResponse(Current current, Daily daily) { }
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Current(String time, Double temperature_2m, Integer weather_code, Integer is_day) { }
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Daily(List<String> time, List<Double> temperature_2m_min, List<Double> temperature_2m_max) { }
}
