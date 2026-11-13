package com.practika.ms_grading.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_grading.client.ContentClient;
import com.practika.ms_grading.client.IdentityClient;
import com.practika.ms_grading.client.AcademicClient;
import com.practika.ms_grading.dto.ObservacionRequest;
import com.practika.ms_grading.dto.RespuestaRequest;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CrossServiceValidator {
    private final IdentityClient identityClient;
    private final ContentClient contentClient;
    private final AcademicClient academicClient;

    public ContentClient.EvaluacionPublicadaRef validarAsignada(Integer run,Integer id,boolean paraEnviar,Authentication auth) {
        if(id==null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Indica idEvaluacionAsignada; el curso y período se obtienen de su publicación");
        if(!esStaff(auth) && !auth.getName().equals(run.toString()))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Solo puedes consultar tu propio trabajo");
        return consultar(()->contentClient.obtenerEvaluacionAsignada(id,run,paraEnviar),"No existe la evaluación publicada");
    }

    public List<Integer> vinculos(Integer id) { return consultar(() -> academicClient.vinculos(id),"No se pudo consultar el historial de la sección"); }
    public List<Integer> cursosVisibles() { return consultar(academicClient::listarCursos,"No se pudieron consultar los cursos").stream().flatMap(c -> vinculos(c.id()).stream()).distinct().toList(); }

    public void validarRespuestaPublicada(RespuestaRequest dto,ContentClient.PreguntaSnapshot pregunta) {
        validarOpciones(dto,pregunta.tipo(),pregunta.opciones());
    }

    private void validarOpciones(RespuestaRequest dto,String tipo,List<ContentClient.OpcionRef> opciones) {
        var ids=dto.idsOpciones()==null?List.<Integer>of():dto.idsOpciones();
        if(ids.stream().distinct().count()!=ids.size()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"No repitas alternativas");
        var validos=opciones.stream().map(ContentClient.OpcionRef::id).collect(Collectors.toSet());
        if(!validos.containsAll(ids)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Una alternativa no pertenece a la versión publicada de la pregunta");
        if(opciones.isEmpty()) {
            if(!ids.isEmpty()||dto.textoDesarrollo()==null||dto.textoDesarrollo().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Completa el desarrollo de todas las preguntas");
        } else if(ids.isEmpty()||(!"SELECCION_MULTIPLE".equalsIgnoreCase(tipo)&&ids.size()!=1))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Selecciona la cantidad de alternativas permitida por la pregunta");
    }

    public EvaluacionRef validarEvaluacion(Integer run, Integer idActividad, Integer idPrueba, Authentication authentication) {
        if ((idActividad == null) == (idPrueba == null)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Indica una actividad o una prueba, no ambas");
        }
        boolean staff = esStaff(authentication);
        IdentityClient.UsuarioRef usuario = consultar(
                () -> staff ? identityClient.obtenerUsuario(run) : identityClient.obtenerUsuarioActual(),
                "No existe el estudiante indicado");
        if (!staff && !run.equals(usuario.run())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Solo puedes responder usando tu propia cuenta");
        }
        if (!"ESTUDIANTE".equalsIgnoreCase(usuario.rol()) || !Boolean.TRUE.equals(usuario.activo())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Se necesita una cuenta de estudiante activa");
        }
        Integer idUnidad;
        Integer maxIntentos;
        if (idActividad != null) {
            var actividad = consultar(() -> contentClient.obtenerActividad(idActividad), "No existe la actividad");
            if (!staff && !Boolean.TRUE.equals(actividad.estadoActivo())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La actividad está inactiva");
            idUnidad = actividad.idUnidad();
            maxIntentos = actividad.cantidadIntentos();
        } else {
            var prueba = consultar(() -> contentClient.obtenerPrueba(idPrueba), "No existe la prueba");
            if (!staff && !Boolean.TRUE.equals(prueba.estadoActivo())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La prueba está inactiva");
            idUnidad = prueba.idUnidad();
            maxIntentos = prueba.cantidadIntentos();
        }
        if (usuario.seccion() == null || !Boolean.TRUE.equals(usuario.seccion().activo()) || idUnidad == null
                || !Boolean.TRUE.equals(consultar(() -> contentClient.estaUnidadAsignadaASeccion(idUnidad, usuario.seccion().id()),
                        "La unidad no está asignada a tu sección"))) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "La unidad no está asignada a tu sección");
        }
        List<ContentClient.PreguntaRef> preguntas = consultar(
                () -> contentClient.listarPreguntas(idActividad, idPrueba), "No fue posible consultar las preguntas");
        return new EvaluacionRef(maxIntentos == null ? 1 : maxIntentos, preguntas);
    }

    public void validarRespuestaEvaluacion(RespuestaRequest dto, ContentClient.PreguntaRef pregunta) {
        List<Integer> ids = dto.idsOpciones() == null ? List.of() : dto.idsOpciones();
        if (ids.stream().distinct().count() != ids.size()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No repitas alternativas en una respuesta");
        List<ContentClient.OpcionRef> opciones = consultar(
                () -> contentClient.obtenerOpciones(pregunta.id()), "No fue posible consultar las alternativas");
        Set<Integer> validos = opciones.stream().map(ContentClient.OpcionRef::id).collect(Collectors.toSet());
        if (!validos.containsAll(ids)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Una alternativa no pertenece a la pregunta indicada");
        if (opciones.isEmpty()) {
            if (!ids.isEmpty() || dto.textoDesarrollo() == null || dto.textoDesarrollo().isBlank()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Completa el texto de todas las preguntas antes de enviar");
            }
        } else {
            if (ids.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Selecciona una alternativa en todas las preguntas");
            if (!"SELECCION_MULTIPLE".equalsIgnoreCase(pregunta.tipo()) && ids.size() != 1) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Esta pregunta permite seleccionar solo una alternativa");
            }
        }
    }

    public void validarPuntaje(Integer idPregunta, BigDecimal puntaje) {
        ContentClient.PreguntaRef pregunta = consultar(
                () -> contentClient.obtenerPregunta(idPregunta), "No existe la pregunta de esta respuesta");
        if (puntaje.compareTo(pregunta.puntajeMaximo()) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El puntaje supera el máximo de la pregunta");
        }
    }

    public void validarAccesoRespuesta(Integer run, Integer idPregunta, Authentication auth) {
        var pregunta = consultar(() -> contentClient.obtenerPregunta(idPregunta), "No existe la pregunta");
        validarEvaluacion(run, pregunta.idActividad(), pregunta.idPrueba(), auth);
    }

    public void validarObservacion(ObservacionRequest dto, Authentication authentication) {
        if ((dto.idActividad() == null) == (dto.idPrueba() == null)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La observación debe referirse a una actividad o a una prueba");
        }
        IdentityClient.UsuarioRef usuario = consultar(
                () -> identityClient.obtenerUsuario(dto.runEstudiante()), "No existe el estudiante indicado");
        if (!"ESTUDIANTE".equalsIgnoreCase(usuario.rol()) || Boolean.FALSE.equals(usuario.activo())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No se puede dejar una observación a una cuenta desactivada");
        }
        AcademicClient.CursoPortalRef curso = consultar(
                () -> academicClient.obtenerCursoPortal(dto.idCursoPortal()), "No existe el curso del portal indicado");
        if (!Boolean.TRUE.equals(consultar(()->identityClient.tieneMatricula(curso.idSeccion(),dto.runEstudiante(),false),
                "No se pudo consultar la matrícula del estudiante"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El estudiante no pertenece al curso indicado");
        }
        Integer idUnidad;
        if (dto.idActividad() != null) {
            ContentClient.ActividadRef actividad = consultar(
                    () -> contentClient.obtenerActividad(dto.idActividad()), "No existe la actividad indicada");
            if (!Boolean.TRUE.equals(actividad.estadoActivo())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La actividad está inactiva");
            idUnidad = actividad.idUnidad();
        } else {
            ContentClient.PruebaRef prueba = consultar(
                    () -> contentClient.obtenerPrueba(dto.idPrueba()), "No existe la prueba indicada");
            if (!Boolean.TRUE.equals(prueba.estadoActivo())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La prueba está inactiva");
            idUnidad = prueba.idUnidad();
        }
        final Integer unidadEvaluada = idUnidad;
        if (unidadEvaluada == null || !Boolean.TRUE.equals(consultar(
                () -> contentClient.estaUnidadAsignada(unidadEvaluada, dto.idCursoPortal()),
                "La unidad no está asignada al curso indicado"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El contenido no pertenece al curso indicado");
        }
    }

    public void validarAccesoCursoPortal(Integer idCursoPortal) {
        if (idCursoPortal == null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Esta observación histórica no tiene un curso asociado y no se puede editar ni eliminar desde el portal");
        }
        consultar(() -> academicClient.obtenerCursoPortal(idCursoPortal), "No existe el curso del portal indicado");
    }

    private boolean esStaff(Authentication authentication) {
        return authentication.getAuthorities().stream().anyMatch(a ->
                a.getAuthority().equals("ROLE_PROFESOR"));
    }

    private <T> T consultar(java.util.function.Supplier<T> request, String notFoundMessage) {
        try {
            return request.get();
        } catch (FeignException ex) {
            if (ex.status() == 404) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, notFoundMessage);
            if (ex.status() == 401) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Inicia sesión para continuar.");
            if (ex.status() == 403) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permisos para validar la referencia relacionada");
            if (ex.status() == 409) throw new ResponseStatusException(HttpStatus.CONFLICT,"La evaluación o su curso están cerrados");
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "No se pudo consultar un servicio relacionado", ex);
        }
    }

    public record EvaluacionRef(int maxIntentos, List<ContentClient.PreguntaRef> preguntas) {}
}
