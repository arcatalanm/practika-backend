package com.practika.ms_grading.service;

import java.util.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import tools.jackson.databind.json.JsonMapper;
import com.practika.ms_grading.client.ContentClient.*;
import com.practika.ms_grading.dto.*;
import com.practika.ms_grading.model.*;
import com.practika.ms_grading.repository.*;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class EntregaService {
    private final EntregaRepository entregas;
    private final RespuestaRepository respuestas;
    private final RespuestaOpcionRepository opciones;
    private final EstadoRevisionRepository estados;
    private final CrossServiceValidator validator;
    private final JsonMapper json;

    @Transactional(readOnly=true)
    public EstadoEntregaResponse estado(Integer run,Integer idEvaluacion,Authentication auth) {
        var evaluacion=validator.validarAsignada(run,idEvaluacion,false,auth);
        var resultado=estadoValidado(run,evaluacion,auth);
        boolean habilitada=resultado.puedeReintentar();
        if(habilitada && !docente(auth)) {
            try {validator.validarAsignada(run,idEvaluacion,true,auth);}
            catch(ResponseStatusException ex) {
                if(ex.getStatusCode().value()==403||ex.getStatusCode().value()==409) habilitada=false; else throw ex;
            }
        }
        return new EstadoEntregaResponse(resultado.intentosUsados(),resultado.maxIntentos(),false,habilitada,resultado.ultimaEntrega());
    }

    private EstadoEntregaResponse estadoValidado(Integer run,EvaluacionPublicadaRef evaluacion,Authentication auth) {
        var historial=entregas.findByRunEstudianteAndIdEvaluacionAsignadaOrderByNumeroIntentoDesc(run,evaluacion.idEvaluacionAsignada());
        var ultima=historial.isEmpty()?null:historial.getFirst();
        int usados=ultima==null?0:ultima.getNumeroIntento();
        boolean autorizado=ultima!=null && "FINALIZADO".equals(ultima.getEstado()) && Boolean.TRUE.equals(ultima.getPermiteReintento());
        int maximos=autorizado?Math.max(evaluacion.cantidadIntentos(),usados+1):evaluacion.cantidadIntentos();
        boolean permitido=Boolean.TRUE.equals(evaluacion.activa()) && (ultima==null?usados<maximos:autorizado);
        return new EstadoEntregaResponse(usados,maximos,false,permitido,ultima==null?null:detalle(ultima));
    }

    @Transactional
    public EntregaResponse crear(EntregaRequest request,Authentication auth) {
        var evaluacion=validator.validarAsignada(request.runEstudiante(),request.idEvaluacionAsignada(),true,auth);
        if((request.idActividad()!=null&&!Objects.equals(request.idActividad(),evaluacion.idActividad()))
                ||(request.idPrueba()!=null&&!Objects.equals(request.idPrueba(),evaluacion.idPrueba())))
            throw error(HttpStatus.BAD_REQUEST,"La actividad o prueba no corresponde a esta publicación");
        if(evaluacion.preguntas().isEmpty()) throw error(HttpStatus.BAD_REQUEST,"La evaluación publicada no tiene preguntas");
        var ids=request.respuestas().stream().map(EntregaRequest.Item::idPregunta).toList();
        var esperados=evaluacion.preguntas().stream().map(PreguntaSnapshot::id).collect(Collectors.toSet());
        if(ids.size()!=esperados.size()||ids.stream().distinct().count()!=ids.size()||!esperados.equals(new HashSet<>(ids)))
            throw error(HttpStatus.BAD_REQUEST,"Responde todas las preguntas de esta versión, sin repetirlas");
        var estado=estadoValidado(request.runEstudiante(),evaluacion,auth);
        if(!estado.puedeReintentar()||request.numeroIntento()!=estado.intentosUsados()+1||request.numeroIntento()>estado.maxIntentos())
            throw error(HttpStatus.CONFLICT,"El intento ya fue enviado o necesita autorización del profesor");
        if(estado.ultimaEntrega()!=null) {
            var anterior=obtenerBloqueada(estado.ultimaEntrega().id());
            if(!"FINALIZADO".equals(anterior.getEstado())||!Boolean.TRUE.equals(anterior.getPermiteReintento()))
                throw error(HttpStatus.CONFLICT,"Espera la revisión y autorización del profesor");
            anterior.setPermiteReintento(false);
        }
        var preguntas=evaluacion.preguntas().stream().collect(Collectors.toMap(PreguntaSnapshot::id,Function.identity()));
        for(var item:request.respuestas()) validator.validarRespuestaPublicada(new RespuestaRequest(request.runEstudiante(),item.idPregunta(),
                request.numeroIntento(),item.textoDesarrollo(),item.idsOpciones()),preguntas.get(item.idPregunta()));
        var entrega=new Entrega();entrega.setRunEstudiante(request.runEstudiante());entrega.setNumeroIntento(request.numeroIntento());
        entrega.setFechaEntrega(LocalDateTime.now());copiarContexto(entrega,evaluacion);
        try {entrega=entregas.saveAndFlush(entrega);}
        catch(DataIntegrityViolationException ex){throw error(HttpStatus.CONFLICT,"Este intento ya fue enviado; actualiza la evaluación");}
        var pendiente=estados.findByCodigoIgnoreCase("PENDIENTE").orElseThrow(()->error(HttpStatus.CONFLICT,"Estado de revisión no configurado"));
        for(var item:request.respuestas()) {
            var respuesta=new Respuesta();respuesta.setIdEntrega(entrega.getId());respuesta.setRunEstudiante(entrega.getRunEstudiante());
            respuesta.setIdPregunta(item.idPregunta());respuesta.setNumeroIntento(entrega.getNumeroIntento());respuesta.setFechaEntrega(entrega.getFechaEntrega());
            respuesta.setTextoDesarrollo(item.textoDesarrollo());respuesta.setEstadoRevisionTipo(pendiente);respuesta=respuestas.saveAndFlush(respuesta);
            for(Integer id:item.idsOpciones()==null?List.<Integer>of():item.idsOpciones()) opciones.save(new RespuestaOpcion(respuesta.getId(),id));
        }
        opciones.flush();return detalle(entrega);
    }

    @Transactional(readOnly=true)
    public List<EntregaResponse> listar(Authentication auth) {
        return listar(auth, null);
    }
    @Transactional(readOnly=true)
    public List<EntregaResponse> listar(Authentication auth, Integer idCursoPortal) {
        List<Integer> cursos;
        if (idCursoPortal == null) cursos = validator.cursosVisibles();
        else {
            validator.validarAccesoCursoPortal(idCursoPortal);
            cursos = validator.vinculos(idCursoPortal);
        }
        return entregas.findByIdCursoPortalInOrderByFechaEntregaDesc(cursos).stream().map(this::detalle).toList();
    }
    @Transactional(readOnly=true)
    public List<EntregaResponse> propias(Authentication auth) {
        return entregas.findByRunEstudianteOrderByFechaEntregaDesc(Integer.valueOf(auth.getName())).stream().map(this::detalle).toList();
    }

    @Transactional(readOnly=true)
    public List<Respuesta> respuestasVisibles(Integer run,Integer pregunta,Authentication auth) {
        var visibles=docente(auth)?entregas.findByIdCursoPortalInOrderByFechaEntregaDesc(validator.cursosVisibles())
                :entregas.findByRunEstudianteOrderByFechaEntregaDesc(Integer.valueOf(auth.getName()));
        var resultado=new ArrayList<>(respuestas.findByIdEntregaIn(visibles.stream().map(Entrega::getId).toList()));
        if(!docente(auth))resultado.addAll(respuestas.findByRunEstudianteAndIdEntregaIsNull(Integer.valueOf(auth.getName())));
        return resultado.stream().filter(r->run==null||run.equals(r.getRunEstudiante()))
                .filter(r->pregunta==null||pregunta.equals(r.getIdPregunta())).toList();
    }

    @Transactional
    public EntregaResponse permitirReintento(Integer id,Authentication auth) {
        var entrega=obtenerBloqueada(id);var evaluacion=autorizar(entrega,auth);
        var estado=estadoValidado(entrega.getRunEstudiante(),evaluacion,auth);
        if(!Boolean.TRUE.equals(evaluacion.activa())||!"FINALIZADO".equals(entrega.getEstado())||estado.ultimaEntrega()==null||!id.equals(estado.ultimaEntrega().id()))
            throw error(HttpStatus.CONFLICT,"Solo se habilita un reintento para la última entrega finalizada de una versión vigente");
        entrega.setPermiteReintento(true);return detalle(entregas.save(entrega));
    }
    @Transactional
    public EntregaResponse comentar(Integer id,String comentario,Authentication auth) {
        var entrega=obtenerBloqueada(id);autorizar(entrega,auth);entrega.setComentario(comentario.trim());return detalle(entregas.save(entrega));
    }

    @Transactional
    public Respuesta revisar(Integer id,RevisionRequest request,Authentication auth) {
        var respuesta=respuestas.findById(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la respuesta"));
        if(respuesta.getIdEntrega()==null) throw error(HttpStatus.CONFLICT,"Vincula esta respuesta histórica a una evaluación antes de revisarla");
        var entrega=obtenerBloqueada(respuesta.getIdEntrega());autorizar(entrega,auth);
        if(!"EN_REVISION".equals(entrega.getEstado())) throw error(HttpStatus.CONFLICT,"La revisión de esta entrega ya finalizó");
        var original=snapshot(entrega).preguntas().stream().filter(p->p.id().equals(respuesta.getIdPregunta())).findFirst()
                .orElseThrow(()->error(HttpStatus.CONFLICT,"Falta la pregunta en el contenido histórico de la entrega"));
        if(request.puntajeObtenido()==null||request.puntajeObtenido().signum()<0||request.puntajeObtenido().compareTo(original.puntajeMaximo())>0)
            throw error(HttpStatus.BAD_REQUEST,"El puntaje debe estar entre cero y el máximo de la versión respondida");
        respuesta.setPuntajeObtenido("REVISADA".equalsIgnoreCase(request.estadoRevision())?request.puntajeObtenido():null);
        respuesta.setEstadoRevisionTipo(estados.findByCodigoIgnoreCase(request.estadoRevision()).orElseThrow(()->error(HttpStatus.BAD_REQUEST,"Estado de revisión no configurado")));
        respuestas.saveAndFlush(respuesta);
        var items=respuestas.findForRevision(entrega.getId());
        if(!items.isEmpty()&&items.stream().allMatch(r->"REVISADA".equals(r.getEstadoRevision())&&r.getPuntajeObtenido()!=null)) {
            entrega.setEstado("FINALIZADO");entrega.setFechaRevision(LocalDateTime.now());entregas.save(entrega);
        }
        return respuesta;
    }

    @Transactional(readOnly=true)
    public void validarAccesoRespuesta(Respuesta r,Authentication auth) {
        if(r.getIdEntrega()!=null) {autorizar(obtener(r.getIdEntrega()),auth);return;}
        if(!auth.getName().equals(r.getRunEstudiante().toString()))
            throw error(HttpStatus.FORBIDDEN,"Las respuestas históricas sin contexto solo son visibles para su estudiante hasta vincularlas a un curso");
    }

    /** Explicit reconstruction: never infer a historical course from the student's current section. */
    @Transactional
    public EntregaResponse vincularHistorica(Integer id,Integer idEvaluacion,Authentication auth) {
        var entrega=obtenerBloqueada(id);
        if(entrega.getIdEvaluacionAsignada()!=null) throw error(HttpStatus.CONFLICT,"La entrega ya tiene un contexto inmutable");
        var eval=validator.validarAsignada(entrega.getRunEstudiante(),idEvaluacion,false,auth);
        if(!Objects.equals(entrega.getIdActividad(),eval.idActividad())||!Objects.equals(entrega.getIdPrueba(),eval.idPrueba()))
            throw error(HttpStatus.BAD_REQUEST,"La publicación debe corresponder a la actividad o prueba histórica");
        comprobarHistoricas(respuestas.findByIdEntregaOrderByIdAsc(id),eval);
        copiarContexto(entrega,eval);entrega.setSnapshotReconstruido(true);entregas.saveAndFlush(entrega);return detalle(entrega);
    }

    @Transactional
    public EntregaResponse importarHistoricas(Integer run,Integer idEvaluacion,Integer intento,Authentication auth) {
        var eval=validator.validarAsignada(run,idEvaluacion,false,auth);
        var ids=eval.preguntas().stream().map(PreguntaSnapshot::id).toList();
        var items=respuestas.findByRunEstudianteAndIdPreguntaIn(run,ids).stream()
                .filter(r->r.getIdEntrega()==null&&r.getNumeroIntento().equals(intento)).toList();
        if(items.isEmpty()) throw error(HttpStatus.NOT_FOUND,"No hay respuestas históricas sin entrega para ese intento y publicación");
        comprobarHistoricas(items,eval);
        var entrega=new Entrega();entrega.setRunEstudiante(run);entrega.setNumeroIntento(intento);
        entrega.setFechaEntrega(items.stream().map(Respuesta::getFechaEntrega).filter(Objects::nonNull).min(Comparator.naturalOrder()).orElse(LocalDateTime.now()));
        copiarContexto(entrega,eval);entrega.setSnapshotReconstruido(true);entrega=entregas.saveAndFlush(entrega);
        for(var r:items)r.setIdEntrega(entrega.getId());respuestas.saveAllAndFlush(items);
        if(items.stream().allMatch(r->"REVISADA".equals(r.getEstadoRevision())&&r.getPuntajeObtenido()!=null)) {
            entrega.setEstado("FINALIZADO");entrega.setFechaRevision(LocalDateTime.now());
        }
        return detalle(entrega);
    }
    private void comprobarHistoricas(List<Respuesta> items,EvaluacionPublicadaRef eval) {
        var ids=eval.preguntas().stream().map(PreguntaSnapshot::id).collect(Collectors.toSet());
        if(items.stream().anyMatch(r->!ids.contains(r.getIdPregunta())))
            throw error(HttpStatus.CONFLICT,"La publicación no contiene todas las preguntas históricas; restaura su versión original antes de vincular");
        if(items.stream().map(Respuesta::getIdPregunta).distinct().count()!=items.size())
            throw error(HttpStatus.CONFLICT,"Hay respuestas históricas duplicadas para una misma pregunta");
    }
    private EvaluacionPublicadaRef autorizar(Entrega entrega,Authentication auth) {
        if(entrega.getIdEvaluacionAsignada()==null) {
            if(auth.getName().equals(entrega.getRunEstudiante().toString()))return null;
            throw error(HttpStatus.CONFLICT,"Esta entrega histórica necesita un curso y una evaluación publicados antes de su revisión");
        }
        return validator.validarAsignada(entrega.getRunEstudiante(),entrega.getIdEvaluacionAsignada(),false,auth);
    }
    private void copiarContexto(Entrega e,EvaluacionPublicadaRef eval) {
        e.setIdEvaluacionAsignada(eval.idEvaluacionAsignada());e.setIdCursoPortal(eval.idCursoPortal());e.setIdPeriodoAcademico(eval.idPeriodoAcademico());
        e.setIdSeccion(eval.idSeccion());e.setIdActividad(eval.idActividad());e.setIdPrueba(eval.idPrueba());
        // Student-visible snapshots never retain the correct-answer flag from staff reconstructions.
        var qs=eval.preguntas().stream().map(p->new PreguntaSnapshot(p.id(),p.texto(),p.tipo(),p.puntajeMaximo(),p.opciones().stream()
                .map(o->new OpcionRef(o.id(),o.texto(),null)).toList(),p.materiales())).toList();
        e.setSnapshotEvaluacion(json.writeValueAsString(new EvaluacionPublicadaRef(eval.idEvaluacionAsignada(),eval.idCursoPortal(),eval.idPeriodoAcademico(),eval.idSeccion(),
                eval.version(),eval.idActividad(),eval.idPrueba(),eval.titulo(),eval.cantidadIntentos(),eval.fechaAplicacion(),eval.publicadaEn(),eval.activa(),qs,eval.materiales())));
    }
    private EvaluacionPublicadaRef snapshot(Entrega e){return json.readValue(e.getSnapshotEvaluacion(),EvaluacionPublicadaRef.class);}
    private Entrega obtener(Integer id){return entregas.findById(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la entrega"));}
    private Entrega obtenerBloqueada(Integer id){return entregas.findForUpdate(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la entrega"));}
    private boolean docente(Authentication auth){return auth.getAuthorities().stream().anyMatch(a->a.getAuthority().equals("ROLE_PROFESOR"));}
    private EntregaResponse detalle(Entrega entrega) {
        var items=respuestas.findByIdEntregaOrderByIdAsc(entrega.getId()).stream().map(r->new EntregaResponse.Item(r.getId(),r.getIdPregunta(),r.getTextoDesarrollo(),
                opciones.findById_IdRespuesta(r.getId()).stream().map(o->o.getId().getIdOpcion()).toList(),r.getPuntajeObtenido(),r.getEstadoRevision())).toList();
        BigDecimal total="FINALIZADO".equals(entrega.getEstado())?items.stream().map(EntregaResponse.Item::puntajeObtenido).filter(Objects::nonNull).reduce(BigDecimal.ZERO,BigDecimal::add):null;
        var eval=entrega.getSnapshotEvaluacion()==null?null:snapshot(entrega);
        return new EntregaResponse(entrega.getId(),entrega.getRunEstudiante(),entrega.getIdActividad(),entrega.getIdPrueba(),entrega.getNumeroIntento(),entrega.getFechaEntrega(),
                entrega.getEstado(),Boolean.TRUE.equals(entrega.getPermiteReintento()),total,entrega.getFechaRevision(),entrega.getComentario(),items,
                entrega.getIdEvaluacionAsignada(),entrega.getIdCursoPortal(),entrega.getIdPeriodoAcademico(),entrega.getIdSeccion(),
                eval==null?"Registro histórico sin contexto":eval.titulo(),eval==null?null:eval.version(),Boolean.TRUE.equals(entrega.getSnapshotReconstruido()),eval==null?List.of():eval.preguntas());
    }
    private ResponseStatusException error(HttpStatus status,String message){return new ResponseStatusException(status,message);}
}
