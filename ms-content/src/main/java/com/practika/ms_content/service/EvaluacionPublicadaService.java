package com.practika.ms_content.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.Authentication;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import tools.jackson.databind.json.JsonMapper;
import com.practika.ms_content.client.IdentityClient;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.dto.UnidadDetalleResponse.*;
import com.practika.ms_content.model.*;
import com.practika.ms_content.repository.*;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class EvaluacionPublicadaService {
    private final EvaluacionAsignadaRepository evaluaciones;
    private final ArchivoEvaluacionRepository copias;
    private final ArchivoRecursoRepository archivos;
    private final UnidadCursoRepository asignaciones;
    private final EvaluacionService autoria;
    private final PreguntaRepository preguntas;
    private final OpcionRepository opciones;
    private final MaterialRepository materiales;
    private final UnidadRepository unidades;
    private final CursoPortalService acceso;
    private final IdentityClient identity;
    private final JsonMapper json;

    /** Upgrade bootstrap only: create a baseline for existing assignments, never replace a version. */
    @Transactional
    public void inicializarExistentes() {
        for(var id:asignaciones.findIdsPendientesDePublicacion()) publicarAsignacion(id,false);
    }

    @Transactional
    public List<EvaluacionPublicadaResponse> publicarCurso(Integer idCurso,Authentication auth) {
        throw error(HttpStatus.GONE,"Selecciona cada actividad o prueba que quieras trabajar con la sección");
    }

    public record Seleccion(Integer idEvaluacion) {}

    @Transactional(readOnly=true)
    public List<Seleccion> seleccion(Integer idCurso, Authentication auth) {
        acceso.validarAcceso(idCurso, auth);
        return asignacionesCompartidas(idCurso).stream()
                .flatMap(a -> evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(a.getId()).stream())
                .filter(e -> Boolean.TRUE.equals(e.getActiva())).map(e -> new Seleccion(e.getIdEvaluacion())).distinct().toList();
    }

    /** Select exactly one source evaluation; previous versions and deliveries are retained. */
    @Transactional
    public void seleccionar(Integer idCurso, Integer idEvaluacion, boolean seleccionar, Authentication auth) {
        var user = identity.obtenerUsuarioActual();
        if (!"PROFESOR".equals(user.rol()) || !Boolean.TRUE.equals(user.activo()))
            throw error(HttpStatus.FORBIDDEN,"Solo el profesor de la sección selecciona sus evaluaciones");
        acceso.validarAcceso(idCurso, auth);
        var context = curso(idCurso);
        if (!Boolean.TRUE.equals(context.activo())) throw error(HttpStatus.CONFLICT,"La sección está inactiva");
        var source = autoria.buscarPorId(idEvaluacion);
        var unit = unidades.findForUpdate(source.getIdUnidad()).orElseThrow(() -> error(HttpStatus.NOT_FOUND,"No existe la unidad"));
        if (!Objects.equals(unit.getIdAsignatura(), context.idAsignatura()))
            throw error(HttpStatus.BAD_REQUEST,"La evaluación debe pertenecer a la asignatura seleccionada");
        if (!seleccionar) {
            asignacionesCompartidas(idCurso).stream()
                    .flatMap(a -> evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(a.getId()).stream())
                    .filter(e -> idEvaluacion.equals(e.getIdEvaluacion())).forEach(e -> e.setActiva(false));
            return;
        }
        var assignment = asignaciones.findByIdCurso(idCurso).stream().filter(a -> unit.getId().equals(a.getIdUnidad())).findFirst().orElse(null);
        if (assignment == null) {
            assignment = new UnidadCurso(); assignment.setIdUnidad(unit.getId()); assignment.setIdCurso(idCurso);
            assignment.setRunProfesor(user.run()); assignment.setPublicacionInicializada(true);
            assignment = asignaciones.saveAndFlush(assignment);
        }
        final var currentAssignment=assignment;
        asignacionesCompartidas(idCurso).stream().filter(a -> !a.getId().equals(currentAssignment.getId()))
                .flatMap(a -> evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(a.getId()).stream())
                .filter(e -> idEvaluacion.equals(e.getIdEvaluacion())).forEach(e -> e.setActiva(false));
        var previous = evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(assignment.getId());
        var qs = source.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD ? preguntas.findByIdActividad(source.getId()) : preguntas.findByIdPrueba(source.getId());
        if (!Boolean.TRUE.equals(source.getEstadoActivo()) || qs.isEmpty())
            throw error(HttpStatus.CONFLICT,"La evaluación debe estar activa y tener preguntas antes de seleccionarla");
        publicar(assignment, source, qs, previous, true, user.run());
    }

    @Transactional
    public void publicarAsignacion(Integer idAsignacion,boolean actualizar) {
        publicarAsignacion(idAsignacion,actualizar,null);
    }
    private void publicarAsignacion(Integer idAsignacion,boolean actualizar,Integer publicador) {
        var a=asignaciones.findForUpdate(idAsignacion).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la asignación"));
        if(!actualizar && Boolean.TRUE.equals(a.getPublicacionInicializada()))return;
        var previas=evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(a.getId());
        for (var fuente : autoria.listarDeUnidad(a.getIdUnidad())) {
            boolean actividad = fuente.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD;
            var qs = actividad ? preguntas.findByIdActividad(fuente.getId()) : preguntas.findByIdPrueba(fuente.getId());
            publicar(a, fuente, qs, previas, actualizar, publicador);
        }
        a.setPublicacionInicializada(true);
    }

    private void publicar(UnidadCurso a, Evaluacion fuente, List<Pregunta> qs,
            List<EvaluacionAsignada> anteriores, boolean actualizar, Integer publicador) {
        String titulo = fuente.getTitulo();
        Integer intentos = fuente.getCantidadIntentos();
        LocalDateTime fecha = fuente instanceof Prueba prueba ? prueba.getFechaAplicacion() : null;
        Boolean activa = fuente.getEstadoActivo();
        var ultima=anteriores.stream().filter(e -> Objects.equals(e.getIdEvaluacion(), fuente.getIdEvaluacion())).findFirst().orElse(null);
        if(!actualizar && ultima!=null) return;
        if(!Boolean.TRUE.equals(activa)||qs.isEmpty()) {
            if(actualizar && ultima!=null) ultima.setActiva(false);
            return;
        }
        var ordenadas=qs.stream().sorted(Comparator.comparing(Pregunta::getId)).map(this::pregunta).toList();
        var adjuntos=materiales.findByEvaluacionIdEvaluacionOrderByIdAsc(fuente.getIdEvaluacion()).stream()
                .filter(m->Boolean.TRUE.equals(m.getActivo())).sorted(Comparator.comparing(Material::getId)).map(this::material).toList();
        var contenido=new EvaluacionPublicadaResponse.Contenido(titulo,intentos,fecha,ordenadas,adjuntos);
        String huella=sha(json.writeValueAsString(contenido));
        if(ultima!=null && huella.equals(ultima.getHuellaOrigen())) { ultima.setActiva(true);return; }
        if(ultima!=null) ultima.setActiva(false);
        var nueva=new EvaluacionAsignada();nueva.setIdAsignacion(a.getId());nueva.setEvaluacion(fuente);
        nueva.setVersion(ultima==null?1:ultima.getVersion()+1);nueva.setPublicadaEn(LocalDateTime.now());nueva.setRunPublicador(publicador==null?a.getRunProfesor():publicador);
        nueva.setHuellaOrigen(huella);nueva.setContenidoSnapshot("{}");
        nueva=evaluaciones.saveAndFlush(nueva);
        final int id=nueva.getId();
        var copiaPreguntas=ordenadas.stream().map(q->new PreguntaDetalle(q.id(),q.texto(),q.tipo(),q.puntajeMaximo(),q.opciones(),copiarMateriales(q.materiales(),id))).toList();
        nueva.setContenidoSnapshot(json.writeValueAsString(new EvaluacionPublicadaResponse.Contenido(titulo,intentos,fecha,copiaPreguntas,copiarMateriales(adjuntos,id))));
    }

    private String sha(String value) {
        try {return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));}
        catch(java.security.NoSuchAlgorithmException ex){throw new IllegalStateException(ex);}
    }
    private PreguntaDetalle pregunta(Pregunta p) {
        var opts=opciones.findByIdPregunta(p.getId()).stream().sorted(Comparator.comparing(Opcion::getId))
                .map(o->new OpcionDetalle(o.getId(),o.getTexto(),o.getEsCorrecta())).toList();
        var mats=materiales.findByIdPreguntaOrderByIdAsc(p.getId()).stream().filter(m->Boolean.TRUE.equals(m.getActivo())).map(this::material).toList();
        return new PreguntaDetalle(p.getId(),p.getTexto(),p.getTipo(),p.getPuntajeMaximo(),opts,mats);
    }
    private MaterialDetalle material(Material m) {
        return new MaterialDetalle(m.getId(),m.getTipo(),m.getContenidoUrl(),m.getActivo(),m.getTitulo(),m.getContenidoTexto());
    }
    private List<MaterialDetalle> copiarMateriales(List<MaterialDetalle> materiales,Integer id) {
        return materiales.stream().map(m->{
            String url=m.contenidoUrl(),prefix="/api/v1/content/recursos/archivos/";
            if(url!=null && url.startsWith(prefix)) {
                var original=archivos.findById(url.substring(prefix.length())).orElseThrow(()->error(HttpStatus.CONFLICT,"Falta un archivo adjunto; corrige el material antes de publicar"));
                var copia=new ArchivoEvaluacion();copia.setId(UUID.randomUUID().toString());copia.setIdEvaluacionAsignada(id);
                copia.setNombre(original.getNombre());copia.setTipoContenido(original.getTipoContenido());copia.setContenido(original.getContenido().clone());
                copias.save(copia);url="/api/v1/content/recursos/evaluaciones/"+copia.getId();
            }
            return new MaterialDetalle(m.id(),m.tipo(),url,m.activo(),m.titulo(),m.contenidoTexto());
        }).toList();
    }

    @Transactional(readOnly=true)
    public List<EvaluacionPublicadaResponse> listar(Integer idCurso,Authentication auth) {
        acceso.validarAcceso(idCurso,auth);
        var newest = new java.util.LinkedHashMap<Integer,EvaluacionAsignada>();
        asignacionesCompartidas(idCurso).stream()
                .flatMap(a -> evaluaciones.findByIdAsignacionOrderByVersionDescIdDesc(a.getId()).stream())
                .filter(e -> Boolean.TRUE.equals(e.getActiva()))
                .sorted(java.util.Comparator.comparing(EvaluacionAsignada::getPublicadaEn).thenComparing(EvaluacionAsignada::getId))
                .forEach(e -> newest.put(e.getIdEvaluacion(),e));
        return newest.values().stream().map(e -> respuesta(e,staff(auth))).toList();
    }

    @Transactional(readOnly=true)
    public EvaluacionPublicadaResponse obtener(Integer id,Authentication auth) {
        var e=evaluaciones.findById(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la evaluación publicada"));
        acceso.validarAcceso(asignacion(e).getIdCurso(),auth);
        return respuesta(e,staff(auth));
    }

    /** The course, its teacher and the target student's enrollment are validated together. */
    @Transactional(readOnly=true)
    public EvaluacionPublicadaResponse paraEstudiante(Integer id,Integer run,boolean paraEnviar,Authentication auth) {
        var result=obtener(id,auth);
        if(!staff(auth) && !auth.getName().equals(run.toString()))
            throw error(HttpStatus.FORBIDDEN,"Solo puedes consultar tu propio trabajo");
        if(paraEnviar && (staff(auth)||!auth.getAuthorities().stream().anyMatch(a->a.getAuthority().equals("ROLE_ESTUDIANTE"))))
            throw error(HttpStatus.FORBIDDEN,"El envío corresponde al estudiante autenticado");
        boolean matriculado;
        try {matriculado=Boolean.TRUE.equals(identity.tieneMatricula(result.idSeccion(),run,paraEnviar));}
        catch(FeignException ex){throw error(HttpStatus.BAD_GATEWAY,"No se pudo comprobar la matrícula del estudiante");}
        if(!matriculado) throw error(HttpStatus.FORBIDDEN,"El estudiante no tiene matrícula en la sección de esta evaluación");
        var curso=curso(result.idCursoPortal());
        if(paraEnviar) {
            try {
                if(!Boolean.TRUE.equals(identity.obtenerSeccion(curso.idSeccion()).activo()))
                    throw error(HttpStatus.CONFLICT,"La sección de esta evaluación está inactiva");
            } catch(FeignException ex){throw error(HttpStatus.BAD_GATEWAY,"No se pudo comprobar el estado de la sección");}
        }
        if(paraEnviar && (!Boolean.TRUE.equals(result.activa())||!Boolean.TRUE.equals(curso.activo())
                ||!Boolean.TRUE.equals(curso.periodoActivo())))
            throw error(HttpStatus.CONFLICT,"Esta versión o su curso/período están cerrados; conserva el historial y abre una evaluación vigente");
        return result;
    }

    @Transactional(readOnly=true)
    public List<UnidadDetalleResponse> unidadesDeCurso(Integer idCurso,Authentication auth) {
        var publicadas=listar(idCurso,auth);
        return asignacionesCompartidas(idCurso).stream().map(UnidadCurso::getIdUnidad).distinct().map(idUnidad -> {
            var contents=publicadas.stream().filter(e -> idUnidad.equals(asignacion(evaluaciones.findById(e.idEvaluacionAsignada()).orElseThrow()).getIdUnidad())).toList();
            var acts=contents.stream().filter(e->e.idActividad()!=null)
                    .map(e->new ActividadDetalle(e.idActividad(),e.titulo(),e.activa(),e.cantidadIntentos(),e.preguntas(),e.idEvaluacionAsignada(),e.version())).toList();
            var tests=contents.stream().filter(e->e.idPrueba()!=null)
                    .map(e->new PruebaDetalle(e.idPrueba(),e.titulo(),e.fechaAplicacion(),e.activa(),e.cantidadIntentos(),e.preguntas(),e.idEvaluacionAsignada(),e.version())).toList();
            return new UnidadDetalleResponse(unidades.findById(idUnidad).orElseThrow(),acts,tests,idCurso);
        }).filter(u -> !u.actividades().isEmpty() || !u.pruebas().isEmpty()).toList();
    }
    @Transactional(readOnly=true)
    public ArchivoEvaluacion archivo(String id,Authentication auth) {
        var archivo=copias.findById(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe el archivo de esta versión"));
        obtener(archivo.getIdEvaluacionAsignada(),auth);return archivo;
    }
    private EvaluacionPublicadaResponse respuesta(EvaluacionAsignada e,boolean staff) {
        var curso=curso(asignacion(e).getIdCurso());
        var c=json.readValue(e.getContenidoSnapshot(),EvaluacionPublicadaResponse.Contenido.class);
        var qs=staff?c.preguntas():c.preguntas().stream().map(q->new PreguntaDetalle(q.id(),q.texto(),q.tipo(),q.puntajeMaximo(),
                q.opciones().stream().map(o->new OpcionDetalle(o.id(),o.texto(),null)).toList(),q.materiales())).toList();
        return new EvaluacionPublicadaResponse(e.getId(),curso.id(),curso.idPeriodoAcademico(),curso.idSeccion(),e.getVersion(),
                e.getIdActividad(),e.getIdPrueba(),c.titulo(),c.cantidadIntentos(),c.fechaAplicacion(),e.getPublicadaEn(),e.getActiva(),qs,c.materiales());
    }
    private List<UnidadCurso> asignacionesCompartidas(Integer idCurso) {
        return acceso.vinculos(idCurso).stream().flatMap(id -> asignaciones.findByIdCurso(id).stream()).toList();
    }
    private UnidadCurso asignacion(EvaluacionAsignada e){return asignaciones.findById(e.getIdAsignacion()).orElseThrow();}
    private CursoContextoResponse curso(Integer id){return acceso.contexto(id);}
    private boolean staff(Authentication auth){return auth.getAuthorities().stream().anyMatch(a->List.of("ROLE_PROFESOR","ROLE_UTP","ROLE_ADMIN").contains(a.getAuthority()));}
    private ResponseStatusException error(HttpStatus code,String message){return new ResponseStatusException(code,message);}
}
