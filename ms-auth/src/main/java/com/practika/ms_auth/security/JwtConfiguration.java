package com.practika.ms_auth.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfiguration {
    @Bean
    JwtValidator jwtValidator(@Value("${jwt.secret}") String secret,
            @Value("${jwt.issuer:practika-ms-auth}") String issuer) {
        return new JwtValidator(secret, issuer);
    }

    @Bean
    JwtAuthenticationFilter jwtAuthenticationFilter(JwtValidator validator, JwtIdentityResolver identities) {
        return new JwtAuthenticationFilter(validator, identities);
    }

    @Bean
    FilterRegistrationBean<JwtAuthenticationFilter> jwtFilterRegistration(JwtAuthenticationFilter filter) {
        var registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }
}
