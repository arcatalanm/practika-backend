package com.practika.ms_grading.client;

import java.util.List;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "academic-service", url = "${ACADEMIC_SERVICE_URL:http://localhost:8082}")
public interface AcademicClient {
    @GetMapping("/api/v1/academic/secciones/asignaturas/{id}/vinculos")
    java.util.List<Integer> vinculos(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/academic/cursos-portal")
    List<CursoPortalRef> listarCursos();

    @GetMapping("/api/v1/academic/cursos-portal/{id}")
    CursoPortalRef obtenerCursoPortal(@PathVariable("id") Integer id);

    record CursoPortalRef(Integer id, Integer idSeccion, Boolean activo) { }
}
