package com.practika.ms_content.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import com.practika.ms_content.dto.*;
import java.util.List;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "academic-service", url = "${ACADEMIC_SERVICE_URL:http://localhost:8082}")
public interface AcademicClient {
    @GetMapping("/api/v1/academic/secciones/asignaturas/{id}/vinculos")
    java.util.List<Integer> vinculos(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/asignaturas/{id}")
    AsignaturaRef obtenerAsignatura(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/objetivos/{id}")
    ObjetivoRef obtenerObjetivo(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/cursos-portal")
    List<CursoPortalResponse> listarCursos();

    @GetMapping("/api/v1/academic/cursos-portal/{id}")
    CursoPortalResponse obtenerCurso(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/cursos-portal/{id}/contexto")
    CursoContextoResponse contextoCurso(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/cursos-portal/{id}/participantes")
    List<IdentityClient.UsuarioRef> participantes(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/cursos-portal/{id}/lista")
    List<IdentityClient.PersonaPublicaRef> lista(@PathVariable("id") Integer id);

    @PostMapping("/api/v1/academic/cursos-portal")
    CursoPortalResponse crearCurso(@RequestBody CursoPortalRequest request);

    @PutMapping("/api/v1/academic/cursos-portal/{id}")
    CursoPortalResponse actualizarCurso(@PathVariable("id") Integer id, @RequestBody CursoPortalRequest request);

    @PatchMapping("/api/v1/academic/cursos-portal/{id}/estado")
    CursoPortalResponse estadoCurso(@PathVariable("id") Integer id, @RequestParam("activo") boolean activo);

    @PostMapping("/api/v1/academic/cursos-portal/{id}/docentes/{run}")
    void asignarDocente(@PathVariable("id") Integer id, @PathVariable("run") Integer run);

    @DeleteMapping("/api/v1/academic/cursos-portal/{id}/docentes/{run}")
    void quitarDocente(@PathVariable("id") Integer id, @PathVariable("run") Integer run);

    @GetMapping("/api/v1/academic/catalogos/periodos-academicos")
    List<PeriodoAcademicoResponse> listarPeriodos();

    @PostMapping("/api/v1/academic/catalogos/periodos-academicos")
    PeriodoAcademicoResponse crearPeriodo(@RequestBody PeriodoAcademicoRequest request);

    @PatchMapping("/api/v1/academic/catalogos/periodos-academicos/{id}/estado")
    PeriodoAcademicoResponse estadoPeriodo(@PathVariable("id") Integer id, @RequestParam("activo") boolean activo);

    record AsignaturaRef(Integer id, String nombre, Boolean activo) {}
    record ObjetivoRef(Integer id, AsignaturaRef asignatura, String descripcion) {}
}
