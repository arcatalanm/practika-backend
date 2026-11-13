package com.practika.ms_auth.controller;

import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.service.FotoPerfilService;
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
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).header("X-Content-Type-Options", "nosniff").body(service.obtener(run));
    }
}
