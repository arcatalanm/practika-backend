package com.practika.ms_content.controller;
import java.util.List;
import java.nio.charset.StandardCharsets;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.http.*;
import org.springframework.core.io.*;
import com.practika.ms_content.dto.EvaluacionPublicadaResponse;
import com.practika.ms_content.service.EvaluacionPublicadaService;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/content") @RequiredArgsConstructor
public class EvaluacionPublicadaController {
    private final EvaluacionPublicadaService service;
    @GetMapping({"/cursos/{idCurso}/evaluaciones", "/secciones/asignaturas/{idCurso}/evaluaciones"})
    public List<EvaluacionPublicadaResponse> listar(@PathVariable Integer idCurso,Authentication auth){return service.listar(idCurso,auth);}
    @PostMapping("/cursos/{idCurso}/evaluaciones/publicar") @PreAuthorize("hasRole('PROFESOR')")
    public List<EvaluacionPublicadaResponse> publicar(@PathVariable Integer idCurso,Authentication auth){return service.publicarCurso(idCurso,auth);}
    @GetMapping({"/cursos/{idCurso}/seleccion", "/secciones/asignaturas/{idCurso}/seleccion"}) @PreAuthorize("hasRole('PROFESOR')")
    public List<EvaluacionPublicadaService.Seleccion> seleccion(@PathVariable Integer idCurso, Authentication auth) {
        return service.seleccion(idCurso,auth);
    }
    @PostMapping({"/cursos/{idCurso}/evaluaciones/{id}/seleccionar", "/secciones/asignaturas/{idCurso}/evaluaciones/{id}/seleccionar"}) @PreAuthorize("hasRole('PROFESOR')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void seleccionar(@PathVariable Integer idCurso, @PathVariable Integer id, Authentication auth) {
        service.seleccionar(idCurso,id,true,auth);
    }
    @DeleteMapping({"/cursos/{idCurso}/evaluaciones/{id}/seleccionar", "/secciones/asignaturas/{idCurso}/evaluaciones/{id}/seleccionar"}) @PreAuthorize("hasRole('PROFESOR')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void retirar(@PathVariable Integer idCurso, @PathVariable Integer id, Authentication auth) {
        service.seleccionar(idCurso,id,false,auth);
    }
    @GetMapping("/evaluaciones/{id}")
    public EvaluacionPublicadaResponse obtener(@PathVariable Integer id,Authentication auth){return service.obtener(id,auth);}
    @GetMapping("/evaluaciones/{id}/estudiantes/{run}")
    public EvaluacionPublicadaResponse estudiante(@PathVariable Integer id,@PathVariable Integer run,
            @RequestParam(defaultValue="false") boolean paraEnviar,Authentication auth){return service.paraEstudiante(id,run,paraEnviar,auth);}
    @GetMapping("/recursos/evaluaciones/{id}")
    public ResponseEntity<Resource> archivo(@PathVariable String id,Authentication auth){
        var file=service.archivo(id,auth);
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(file.getTipoContenido())).cacheControl(CacheControl.noStore())
                .header("X-Content-Type-Options","nosniff")
                .header(HttpHeaders.CONTENT_DISPOSITION,ContentDisposition.inline().filename(file.getNombre(),StandardCharsets.UTF_8).build().toString())
                .body(new ByteArrayResource(file.getContenido()));
    }
}
