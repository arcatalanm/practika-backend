package com.practika.ms_content.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import com.practika.ms_content.model.Unidad;

public record UnidadDetalleResponse(UnidadResponse unidad,
        List<ActividadDetalle> actividades, List<PruebaDetalle> pruebas,Integer idCursoPortal) {
    public UnidadDetalleResponse(Unidad u, List<ActividadDetalle> a, List<PruebaDetalle> p) {
        this(UnidadResponse.from(u), a, p, null);
    }

    public UnidadDetalleResponse(Unidad u, List<ActividadDetalle> a, List<PruebaDetalle> p, Integer idCurso) {
        this(UnidadResponse.from(u), a, p, idCurso);
    }
    public record MaterialDetalle(Integer id, String tipo, String contenidoUrl, Boolean activo,
            String titulo, String contenidoTexto) {}
    public record ActividadDetalle(Integer id, String titulo, Boolean estadoActivo,
            Integer cantidadIntentos, List<PreguntaDetalle> preguntas,Integer idEvaluacionAsignada,Integer version,
            @com.fasterxml.jackson.annotation.JsonInclude(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL) Integer idEvaluacion) {
        public ActividadDetalle(Integer id,String titulo,Boolean activo,Integer intentos,List<PreguntaDetalle> preguntas,Integer publicacion,Integer version){this(id,titulo,activo,intentos,preguntas,publicacion,version,null);}
        public ActividadDetalle(Integer id,String titulo,Boolean activo,Integer intentos,List<PreguntaDetalle> preguntas){this(id,titulo,activo,intentos,preguntas,null,null);}
    }
    public record PruebaDetalle(Integer id, String titulo, LocalDateTime fechaAplicacion,
            Boolean estadoActivo, Integer cantidadIntentos, List<PreguntaDetalle> preguntas,Integer idEvaluacionAsignada,Integer version,
            @com.fasterxml.jackson.annotation.JsonInclude(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL) Integer idEvaluacion) {
        public PruebaDetalle(Integer id,String titulo,LocalDateTime fecha,Boolean activo,Integer intentos,List<PreguntaDetalle> preguntas,Integer publicacion,Integer version){this(id,titulo,fecha,activo,intentos,preguntas,publicacion,version,null);}
        public PruebaDetalle(Integer id,String titulo,LocalDateTime fecha,Boolean activo,Integer intentos,List<PreguntaDetalle> preguntas){this(id,titulo,fecha,activo,intentos,preguntas,null,null);}
    }
    public record PreguntaDetalle(Integer id, String texto, String tipo, BigDecimal puntajeMaximo,
            List<OpcionDetalle> opciones, List<MaterialDetalle> materiales) {}
    public record OpcionDetalle(Integer id, String texto, Boolean esCorrecta) {}
}
