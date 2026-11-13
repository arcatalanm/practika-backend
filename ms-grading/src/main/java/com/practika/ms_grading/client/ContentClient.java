package com.practika.ms_grading.client;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "content-service", url = "${ACTIVITY_SERVICE_URL:http://localhost:8083}")
public interface ContentClient {
    @GetMapping("/api/v1/content/evaluaciones/{id}/estudiantes/{run}")
    EvaluacionPublicadaRef obtenerEvaluacionAsignada(@PathVariable("id") Integer id,@PathVariable("run") Integer run,
            @RequestParam("paraEnviar") boolean paraEnviar);
    record MaterialSnapshot(Integer id,String tipo,String contenidoUrl,Boolean activo,String titulo,String contenidoTexto) {}
    record PreguntaSnapshot(Integer id,String texto,String tipo,BigDecimal puntajeMaximo,
            List<OpcionRef> opciones,List<MaterialSnapshot> materiales) {}
    record EvaluacionPublicadaRef(Integer idEvaluacionAsignada,Integer idCursoPortal,Integer idPeriodoAcademico,Integer idSeccion,
            Integer version,Integer idActividad,Integer idPrueba,String titulo,Integer cantidadIntentos,
            java.time.LocalDateTime fechaAplicacion,java.time.LocalDateTime publicadaEn,Boolean activa,
            List<PreguntaSnapshot> preguntas,List<MaterialSnapshot> materiales) {}
    @GetMapping("/api/v1/content/preguntas/{id}")
    PreguntaRef obtenerPregunta(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/content/preguntas")
    List<PreguntaRef> listarPreguntas(@RequestParam(value="idActividad", required=false) Integer idActividad,
            @RequestParam(value="idPrueba", required=false) Integer idPrueba);

    @GetMapping("/api/v1/content/actividades/{id}")
    ActividadRef obtenerActividad(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/content/pruebas/{id}")
    PruebaRef obtenerPrueba(@PathVariable("id") Integer id);


    @GetMapping("/api/v1/content/preguntas/{id}/opciones")
    List<OpcionRef> obtenerOpciones(@PathVariable("id") Integer id);

    @GetMapping("/api/v1/content/unidades/{idUnidad}/cursos/{idCurso}/asignada")
    Boolean estaUnidadAsignada(@PathVariable("idUnidad") Integer idUnidad, @PathVariable("idCurso") Integer idCurso);

    @GetMapping("/api/v1/content/unidades/{idUnidad}/secciones/{idSeccion}/asignada")
    Boolean estaUnidadAsignadaASeccion(@PathVariable("idUnidad") Integer idUnidad, @PathVariable("idSeccion") Integer idSeccion);

    record PreguntaRef(Integer id, Integer idActividad, Integer idPrueba, BigDecimal puntajeMaximo, String tipo) {}
    record ActividadRef(Integer id, Integer idUnidad, Boolean estadoActivo, Integer cantidadIntentos) {}
    record PruebaRef(Integer id, Integer idUnidad, Boolean estadoActivo, Integer cantidadIntentos) {}
    record OpcionRef(Integer id, String texto, Boolean esCorrecta) {}
}
