package com.practika.ms_academic.service;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_academic.repository.AsignaturaRepository;
import com.practika.ms_academic.dto.CursoContextoResponse;
import com.practika.ms_academic.client.IdentityClient;
import com.practika.ms_academic.dto.CursoPortalRequest;
import com.practika.ms_academic.dto.CursoPortalResponse;
import com.practika.ms_academic.dto.DocentePortalResponse;
import com.practika.ms_academic.model.CursoPortal;
import com.practika.ms_academic.model.DocenteCursoPortal;
import com.practika.ms_academic.model.PeriodoAcademico;
import com.practika.ms_academic.repository.CursoPortalRepository;
import com.practika.ms_academic.repository.DocenteCursoPortalRepository;
import com.practika.ms_academic.repository.PeriodoAcademicoRepository;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class CursoPortalService {
    private final CursoPortalRepository cursos;
    private final IdentityClient identity;
    private final AsignaturaRepository asignaturas;

    /** Automatic section-subject links. There is no classroom or school-year setup. */
    @Transactional
    public List<CursoPortalResponse> listar(Authentication auth) {
        var user = usuarioActual();
        if (!Boolean.TRUE.equals(user.activo())) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "La cuenta está inactiva");
        var sections = tieneRol(auth, "ADMIN", "UTP")
                ? consultar(identity::obtenerSecciones, "No se pudieron consultar las secciones")
                : user.seccion() == null ? List.<IdentityClient.SeccionRef>of() : List.of(user.seccion());
        var subjects = asignaturas.bloquearCatalogo();
        var result = new java.util.ArrayList<CursoPortalResponse>();
        for (var section : sections) {
            if (!Boolean.TRUE.equals(section.activo())) continue;
            var current = cursos.findByIdSeccionAndPeriodoIsNullOrderByIdAsc(section.id());
            for (var subject : subjects) {
                if (!Boolean.TRUE.equals(subject.getActivo())) continue;
                var link = current.stream().filter(c -> subject.getId().equals(c.getIdAsignatura())).findFirst().orElse(null);
                if (link == null) {
                    link = new CursoPortal(); link.setIdSeccion(section.id()); link.setIdAsignatura(subject.getId());
                    link.setNombre(subject.getNombre()); link.setActivo(true);
                    link = cursos.saveAndFlush(link);
                }
                result.add(respuesta(link));
            }
        }
        return result;
    }

    @Transactional(readOnly = true)
    public CursoPortalResponse obtener(Integer id) { return respuesta(buscar(id)); }

    @Transactional
    public CursoPortalResponse crear(CursoPortalRequest dto) {
        throw new ResponseStatusException(HttpStatus.GONE, "Las asignaturas de la sección son automáticas. El administrador asigna profesores y estudiantes a su sección desde Personas");
    }

    @Transactional
    public CursoPortalResponse actualizar(Integer id, CursoPortalRequest dto) {
        throw new ResponseStatusException(HttpStatus.GONE, "Las asignaturas de la sección son automáticas. El administrador asigna profesores y estudiantes a su sección desde Personas");
    }

    @Transactional
    public CursoPortalResponse estado(Integer id, boolean activo) {
        CursoPortal c = buscar(id);
        c.setActivo(activo);
        return respuesta(cursos.save(c));
    }

    @Transactional
    public void asignarDocente(Integer idCurso, Integer run) {
        throw new ResponseStatusException(HttpStatus.GONE, "Las asignaturas de la sección son automáticas. El administrador asigna profesores y estudiantes a su sección desde Personas");
    }

    @Transactional
    public void quitarDocente(Integer idCurso, Integer run) {
        throw new ResponseStatusException(HttpStatus.GONE, "Las asignaturas de la sección son automáticas. El administrador asigna profesores y estudiantes a su sección desde Personas");
    }

    public List<IdentityClient.UsuarioRef> participantes(Integer idCurso, Authentication auth) {
        CursoPortal c = buscar(idCurso);
        validarAcceso(idCurso, usuarioActual(), auth);
        return consultar(() -> identity.obtenerParticipantes(c.getIdSeccion()), "No se pudieron consultar los participantes");
    }

    /** Lista actual del aula. El historial de participantes sigue disponible para la revisión. */
    public List<IdentityClient.PersonaPublicaRef> lista(Integer idCurso, Authentication auth) {
        CursoPortal curso = buscar(idCurso);
        validarAcceso(idCurso, usuarioActual(), auth);
        var personas = new java.util.LinkedHashMap<Integer, IdentityClient.PersonaPublicaRef>();
        var section = consultar(() -> identity.obtenerSeccion(curso.getIdSeccion()), "No existe la sección");
        for (var docente : consultar(() -> identity.obtenerProfesores(section.id()), "No se pudieron consultar los profesores")) {
            personas.put(docente.run(), docente);
        }
        var estudiantes = consultar(() -> identity.obtenerParticipantesActuales(curso.getIdSeccion()),
                "No se pudieron consultar los estudiantes");
        for (var estudiante : estudiantes) {
            personas.putIfAbsent(estudiante.run(), estudiante);
        }
        return personas.values().stream()
                .sorted(java.util.Comparator.comparing((IdentityClient.PersonaPublicaRef p) -> !"PROFESOR".equals(p.rol()))
                        .thenComparing(IdentityClient.PersonaPublicaRef::nombreCompleto, String.CASE_INSENSITIVE_ORDER))
                .toList();
    }

    public void validarAcceso(Integer idCurso, IdentityClient.UsuarioRef user, Authentication auth) {
        CursoPortal c = buscar(idCurso);
        if (!Boolean.TRUE.equals(user.activo())) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "La cuenta está inactiva");
        if (tieneRol(auth, "UTP", "ADMIN")) return;
        IdentityClient.SeccionRef section = consultar(() -> identity.obtenerSeccion(c.getIdSeccion()), "No existe la sección asociada");
        if ("ESTUDIANTE".equalsIgnoreCase(user.rol()) && Boolean.TRUE.equals(consultar(
                ()->identity.tieneMatricula(section.id(),user.run(),false),"No se pudo consultar la matrícula"))) return;
        if ("PROFESOR".equalsIgnoreCase(user.rol())
                && user.seccion() != null && section.id().equals(user.seccion().id()) && Boolean.TRUE.equals(section.activo())) return;
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este curso del portal");
    }

    public void validarAcceso(Integer idCurso, Authentication auth) {
        validarAcceso(idCurso, usuarioActual(), auth);
    }

    private CursoPortalResponse respuesta(CursoPortal c) {
        IdentityClient.SeccionRef seccion = consultar(() -> identity.obtenerSeccion(c.getIdSeccion()), "No existe la sección asociada");
        String seccionNombre = seccion.nivelEducativo();
        String subjectName = c.getIdAsignatura() == null ? null : asignaturas.findById(c.getIdAsignatura())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.CONFLICT, "No existe la asignatura asociada")).getNombre();
        var runs = consultar(() -> identity.obtenerProfesores(seccion.id()), "No se pudieron consultar los profesores").stream()
                .map(d -> new DocentePortalResponse(d.run(), d.nombreCompleto())).toList();
        return new CursoPortalResponse(c.getId(), seccion.id(), seccionNombre, c.getIdAsignatura(), subjectName,
                c.getPeriodo() == null ? null : c.getPeriodo().getId(), "", subjectName, c.getDescripcion(), c.getActivo(), runs);
    }

    @Transactional(readOnly = true)
    public CursoContextoResponse contexto(Integer id, Authentication auth) {
        validarAcceso(id, auth);
        var curso = buscar(id);
        var section = consultar(() -> identity.obtenerSeccion(curso.getIdSeccion()), "No existe la sección");
        return new CursoContextoResponse(curso.getId(), section.id(), curso.getIdAsignatura(),
                curso.getPeriodo() == null ? null : curso.getPeriodo().getId(), curso.getActivo(), true);
    }

    /** Includes old letter/year links so historical content and deliveries stay reachable. */
    @Transactional(readOnly=true)
    public List<Integer> vinculos(Integer id, Authentication auth) {
        validarAcceso(id,auth);
        var current=buscar(id);
        var section=consultar(() -> identity.obtenerSeccion(current.getIdSeccion()), "No existe la sección");
        return cursos.findAllByOrderByIdAsc().stream()
                .filter(c -> java.util.Objects.equals(c.getIdAsignatura(),current.getIdAsignatura()))
                .filter(c -> section.id().equals(consultar(() -> identity.obtenerSeccion(c.getIdSeccion()), "No existe la sección histórica").id()))
                .map(CursoPortal::getId).toList();
    }

    private CursoPortal buscar(Integer id) {
        return cursos.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe curso del portal con ID " + id));
    }

    private IdentityClient.UsuarioRef usuarioActual() {
        return consultar(identity::obtenerUsuarioActual, "No se pudo consultar la cuenta actual");
    }

    private boolean tieneRol(Authentication auth, String... roles) {
        return auth.getAuthorities().stream().anyMatch(a -> java.util.Arrays.stream(roles).anyMatch(r -> a.getAuthority().equals("ROLE_" + r)));
    }

    private <T> T consultar(java.util.function.Supplier<T> request, String notFoundMessage) {
        try { return request.get(); }
        catch (FeignException ex) {
            if (ex.status() == 401) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Inicia sesión para continuar.");
            if (ex.status() == 403) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes permiso para consultar un servicio relacionado");
            if (ex.status() == 404) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, notFoundMessage);
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "No se pudo consultar un servicio relacionado", ex);
        }
    }
}
