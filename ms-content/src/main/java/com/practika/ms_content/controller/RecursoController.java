package com.practika.ms_content.controller;

import java.util.Map;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

/** Resources belong to ms-content and are streamed through the authenticated gateway. */
@RestController
@RequestMapping("/api/v1/content/recursos")
public class RecursoController {
    private static final Map<String, String> TYPES = Map.of(
            "raton.svg", "image/svg+xml", "manzanas.svg", "image/svg+xml",
            "tierra.gif", "image/gif", "flores.mp4", "video/mp4");

    @GetMapping("/{nombre}")
    public ResponseEntity<Resource> obtener(@PathVariable String nombre) {
        String type = TYPES.get(nombre);
        if (type == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe el recurso");
        Resource resource = new ClassPathResource("media/" + nombre);
        if (!resource.exists()) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe el recurso");
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(type))
                .cacheControl(CacheControl.noStore()).header("X-Content-Type-Options", "nosniff").body(resource);
    }
}
