package com.practika.ms_academic.security;

import org.springframework.http.HttpHeaders;
import org.springframework.web.client.RestClient;

/** The token is opaque here; only ms-auth resolves it to a current identity. */
public class AuthIdentityClient {
    private final RestClient client;

    public AuthIdentityClient(RestClient client) {
        this.client = client;
    }

    public Identity resolve(String authorization) {
        return client.get().uri("/api/v1/auth/identity")
                .header(HttpHeaders.AUTHORIZATION, authorization)
                .retrieve().body(Identity.class);
    }

    public record Identity(Integer run, String rol) { }
}
