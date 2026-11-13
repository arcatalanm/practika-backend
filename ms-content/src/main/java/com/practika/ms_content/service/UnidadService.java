package com.practika.ms_content.service;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.client.IdentityClient;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.model.*;
import com.practika.ms_content.repository.*;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class UnidadService {
    private final UnidadRepository unidades;
    private final UnidadCursoRepository asignaciones;
    private final EvaluacionService evaluaciones;
    private final MaterialRepository materiales;
    private final PreguntaRepository preguntas;
    private final OpcionRepository opciones;
    private final IdentityClient identity;
    private final CrossServiceValidator validator;
    private final UnidadAccessService accesoUnidad;
    private final CursoPortalService cursoPortalService;
    private final EvaluacionPublicadaService publicaciones;

    @Transactional
    public UnidadResponse crear(UnidadRequest dto) {
        validator.validarUnidad(dto.idAsignatura(), dto.idObjetivo());
        Unidad unidad = new Unidad();
        aplicar(unidad, dto);
        return UnidadResponse.from(unidades.save(unidad));
    }

    @Transactional
    public UnidadResponse crearEnCurso(Integer idCurso, UnidadEnCursoRequest dto, Authentication auth) {
        throw new ResponseStatusException(HttpStatus.GONE, "UTP crea unidades en el catálogo de asignaturas, sin asignarlas a una sección");
    }

    @Transactional
    public UnidadResponse actualizar(Integer id, UnidadRequest dto) {
        validator.validarUnidad(dto.idAsignatura(), dto.idObjetivo());
        Unidad unidad = buscarUnidad(id);
        if (asignaciones.existsByIdUnidad(id) && (!unidad.getIdAsignatura().equals(dto.idAsignatura())
                || !unidad.getIdObjetivo().equals(dto.idObjetivo()))) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Una unidad asignada conserva su asignatura y objetivo; crea otra unidad para cambiar el contexto curricular");
        }
        aplicar(unidad, dto);
        return UnidadResponse.from(unidades.save(unidad));
    }

    @Transactional
    public void eliminar(Integer id) {
        Unidad unidad = unidades.findForUpdate(id).orElseThrow(() -> noEncontrado("unidad", id));
        if (asignaciones.existsByIdUnidad(id)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "La unidad está asignada a cursos y no se puede eliminar");
        }
        unidades.delete(unidad);
        unidades.flush();
    }

    public List<UnidadDetalleResponse> listar(Integer idAsignatura, Authentication auth) {
        if (esRol(auth, "UTP")) {
            var encontradas = idAsignatura == null ? unidades.findAll() : unidades.findByIdAsignatura(idAsignatura);
            return encontradas.stream().map(u -> construirDetalle(u, true)).toList();
        }
        IdentityClient.UsuarioRef usuario = usuarioActual();
        if ("ESTUDIANTE".equalsIgnoreCase(usuario.rol())) {
            return cursoPortalService.listar(auth).stream()
                    .flatMap(c -> publicaciones.unidadesDeCurso(c.id(), auth).stream())
                    .filter(u -> idAsignatura == null || idAsignatura.equals(u.unidad().idAsignatura())).toList();
        }
        if ("PROFESOR".equalsIgnoreCase(usuario.rol())) {
            var encontradas = idAsignatura == null ? unidades.findAll() : unidades.findByIdAsignatura(idAsignatura);
            return encontradas.stream().map(u -> construirDetalle(u, true)).toList();
        }
        throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                "Tu rol no puede consultar unidades asignadas a un curso");
    }

    public UnidadDetalleResponse detalle(Integer id, Integer idCursoPortal, Authentication auth) {
        if (esRol(auth, "ESTUDIANTE")) {
            var contextos = cursoPortalService.listar(auth).stream()
                    .filter(c -> idCursoPortal == null || idCursoPortal.equals(c.id()))
                    .flatMap(c -> publicaciones.unidadesDeCurso(c.id(), auth).stream())
                    .filter(u -> id.equals(u.unidad().id())).toList();
            if (contextos.size() > 1) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Indica idCursoPortal para elegir el contexto de la unidad");
            }
            return contextos.stream().findFirst().orElseThrow(() ->
                    new ResponseStatusException(HttpStatus.FORBIDDEN,
                            "No tienes esta unidad publicada en el curso indicado"));
        }
        Unidad unidad = buscarUnidad(id);
        validarAccesoUnidad(unidad.getId(), auth);
        return construirDetalle(unidad, esRol(auth, "UTP", "PROFESOR"));
    }

    @Transactional
    public UnidadCursoResponse asignar(UnidadCursoRequest dto, Authentication auth) {
        throw new ResponseStatusException(HttpStatus.GONE, "Selecciona actividades o pruebas individuales para la sección");
    }

    public List<UnidadDetalleResponse> listarDeCurso(Integer idCurso, Authentication auth) {
        if (esRol(auth, "UTP")) {
            cursoPortalService.validarAcceso(idCurso, auth);
            return asignaciones.findByIdCurso(idCurso).stream()
                    .map(a -> construirDetalle(buscarUnidad(a.getIdUnidad()), true)).toList();
        }
        return publicaciones.unidadesDeCurso(idCurso, auth);
    }

    public List<UnidadResponse> unidadesDisponibles(Integer idCurso, Authentication auth) {
        cursoPortalService.validarAcceso(idCurso, usuarioActual(), auth);
        var curso = cursoPortalService.contexto(idCurso);
        return unidades.findDisponibles(curso.idAsignatura(), idCurso).stream()
                .map(UnidadResponse::from).toList();
    }

    public boolean estaAsignada(Integer idUnidad, Integer idCurso) {
        return cursoPortalService.vinculos(idCurso).stream().anyMatch(id -> asignaciones.existsByIdUnidadAndIdCurso(idUnidad,id));
    }

    public boolean estaAsignadaASeccion(Integer idUnidad, Integer idSeccion, Authentication auth) {
        return cursoPortalService.listar(auth).stream()
                .filter(c -> Boolean.TRUE.equals(c.activo()) && idSeccion.equals(c.idSeccion()))
                .anyMatch(c -> estaAsignada(idUnidad,c.id()));
    }

    private UnidadDetalleResponse construirDetalle(Unidad unidad, boolean mostrarCorrectas) {
        var contenido = evaluaciones.listarDeUnidad(unidad.getId());
        var acts = contenido.stream().filter(e -> e.getTipoEvaluacion() == TipoEvaluacion.ACTIVIDAD)
                .filter(a -> mostrarCorrectas || Boolean.TRUE.equals(a.getEstadoActivo()))
                .map(a -> new UnidadDetalleResponse.ActividadDetalle(a.getId(), a.getTitulo(), a.getEstadoActivo(),
                        a.getCantidadIntentos(), preguntas.findByIdActividad(a.getId()).stream()
                                .map(p -> preguntaDetalle(p, mostrarCorrectas)).toList(), null, null, a.getIdEvaluacion())).toList();
        var tests = contenido.stream().filter(e -> e.getTipoEvaluacion() == TipoEvaluacion.PRUEBA)
                .filter(p -> mostrarCorrectas || Boolean.TRUE.equals(p.getEstadoActivo()))
                .map(p -> new UnidadDetalleResponse.PruebaDetalle(p.getId(), p.getTitulo(), ((Prueba) p).getFechaAplicacion(),
                        p.getEstadoActivo(), p.getCantidadIntentos(), preguntas.findByIdPrueba(p.getId()).stream()
                                .map(q -> preguntaDetalle(q, mostrarCorrectas)).toList(), null, null, p.getIdEvaluacion())).toList();
        return new UnidadDetalleResponse(unidad, acts, tests);
    }

    private UnidadDetalleResponse.PreguntaDetalle preguntaDetalle(Pregunta pregunta, boolean mostrarCorrectas) {
        var alternativas = opciones.findByIdPregunta(pregunta.getId()).stream()
                .map(o -> new UnidadDetalleResponse.OpcionDetalle(o.getId(), o.getTexto(),
                        mostrarCorrectas ? o.getEsCorrecta() : null)).toList();
        var apoyos = materiales.findByIdPreguntaOrderByIdAsc(pregunta.getId()).stream()
                .filter(m -> mostrarCorrectas || Boolean.TRUE.equals(m.getActivo()))
                .map(m -> new UnidadDetalleResponse.MaterialDetalle(m.getId(), m.getTipo(), m.getContenidoUrl(),
                        m.getActivo(), m.getTitulo(), m.getContenidoTexto())).toList();
        return new UnidadDetalleResponse.PreguntaDetalle(pregunta.getId(), pregunta.getTexto(), pregunta.getTipo(),
                pregunta.getPuntajeMaximo(), alternativas, apoyos);
    }

    private void validarAccesoUnidad(Integer idUnidad, Authentication auth) {
        accesoUnidad.validarAcceso(idUnidad, auth);
    }

    private IdentityClient.UsuarioRef usuarioActual() {
        try {
            IdentityClient.UsuarioRef usuario = identity.obtenerUsuarioActual();
            if (!Boolean.TRUE.equals(usuario.activo())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "La cuenta está inactiva");
            }
            return usuario;
        } catch (FeignException ex) {
            if (ex.status() == 401) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Inicia sesión para continuar.");
            }
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "No se pudo consultar la cuenta en ms-auth", ex);
        }
    }

    private boolean esRol(Authentication auth, String... roles) {
        return auth.getAuthorities().stream()
                .anyMatch(a -> Arrays.stream(roles).anyMatch(r -> a.getAuthority().equals("ROLE_" + r)));
    }

    private Unidad buscarUnidad(Integer id) {
        return unidades.findById(id).orElseThrow(() -> noEncontrado("unidad", id));
    }

    private ResponseStatusException noEncontrado(String tipo, Integer id) {
        return new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe " + tipo + " con ID " + id);
    }

    private void aplicar(Unidad unidad, UnidadRequest dto) {
        unidad.setIdAsignatura(dto.idAsignatura());
        unidad.setIdObjetivo(dto.idObjetivo());
        unidad.setTitulo(dto.titulo().trim());
        unidad.setDescripcion(dto.descripcion());
    }
}
