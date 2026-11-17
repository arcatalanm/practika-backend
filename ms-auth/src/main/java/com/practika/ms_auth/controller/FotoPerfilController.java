package com.practika.ms_auth.controller;

import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.service.FotoPerfilService;
import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/auth") @RequiredArgsConstructor
public class FotoPerfilController {
    private final FotoPerfilService service;

    @PutMapping(value="/me/foto", consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @org.springframework.security.access.prepost.PreAuthorize("isAuthenticated()")
    public UsuarioResponseDTO guardar(@RequestPart("foto") MultipartFile foto, Authentication auth) {
        return service.guardar(Integer.valueOf(auth.getName()), foto);
    }

    @GetMapping(value="/usuarios/{run}/foto", produces=MediaType.IMAGE_JPEG_VALUE)
    public ResponseEntity<byte[]> obtener(@PathVariable Integer run) {
        // La URL guardada lleva ?v=<uuid> y cambia en cada subida, así que cachear es seguro.
        return ResponseEntity.ok().cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS).cachePrivate())
                .header("X-Content-Type-Options", "nosniff").body(service.obtener(run));
    }
}
