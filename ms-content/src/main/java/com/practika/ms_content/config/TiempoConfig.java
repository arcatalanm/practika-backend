package com.practika.ms_content.config;

import java.net.http.HttpClient;
import java.time.Clock;
import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;
import com.practika.ms_content.service.TiempoService;

@Configuration
public class TiempoConfig {
    @Bean
    TiempoService tiempoService(
            @Value("${weather.api-url:https://api.open-meteo.com}") String url,
            @Value("${weather.location-name:Antonio Varas 666, Providencia}") String ubicacion,
            @Value("${weather.latitude:-33.433047}") double latitude,
            @Value("${weather.longitude:-70.614903}") double longitude) {
        var http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
        var factory = new JdkClientHttpRequestFactory(http);
        factory.setReadTimeout(Duration.ofSeconds(4));
        var client = RestClient.builder().baseUrl(url).requestFactory(factory).build();
        return new TiempoService(client, ubicacion, latitude, longitude, Clock.systemUTC());
    }
}
