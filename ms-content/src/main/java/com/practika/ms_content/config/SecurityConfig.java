package com.practika.ms_content.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import com.practika.ms_content.security.AuthIdentityClient;
import com.practika.ms_content.security.RemoteAuthenticationFilter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;
import java.net.http.HttpClient;
import java.time.Duration;
import com.practika.ms_content.security.SecurityErrorWriter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    @Bean
    AuthIdentityClient authIdentityClient(
            @Value("${services.identity.url:http://localhost:8081}") String url,
            @Value("${services.identity.connect-timeout-ms:2000}") long connectTimeout,
            @Value("${services.identity.read-timeout-ms:3000}") long readTimeout) {
        var httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofMillis(connectTimeout)).build();
        var factory = new JdkClientHttpRequestFactory(httpClient);
        factory.setReadTimeout(Duration.ofMillis(readTimeout));
        return new AuthIdentityClient(RestClient.builder().baseUrl(url).requestFactory(factory).build());
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http, AuthIdentityClient identities) throws Exception {
        return http.csrf(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(errors -> errors
                        .authenticationEntryPoint((request, response, ex) ->
                                SecurityErrorWriter.write(response, request, 401, "Unauthorized",
                                        "Inicia sesión para continuar."))
                        .accessDeniedHandler((request, response, ex) ->
                                SecurityErrorWriter.write(response, request, 403, "Forbidden",
                                        "No tienes permisos para realizar esta operación")))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/error", "/swagger-ui.html", "/swagger-ui/**",
                                "/v3/api-docs", "/v3/api-docs/**").permitAll()
                        .anyRequest().authenticated())
                .addFilterBefore(new RemoteAuthenticationFilter(identities), UsernamePasswordAuthenticationFilter.class)
                .build();
    }
}
