package com.practika.ms_content.service;

import java.util.List;
import java.util.function.Supplier;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import com.practika.ms_content.client.AcademicClient;
import com.practika.ms_content.client.IdentityClient;
import com.practika.ms_content.dto.*;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

/** Compatibility facade. Course rules and persistence belong to ms-academic. */
@Service @RequiredArgsConstructor
public class CursoPortalService {
    private final AcademicClient academic;

    public List<CursoPortalResponse> listar(Authentication auth) { return consultar(academic::listarCursos); }
    public List<Integer> vinculos(Integer id) { return consultar(() -> academic.vinculos(id)); }
    public CursoPortalResponse obtener(Integer id) { return consultar(() -> academic.obtenerCurso(id)); }
    public CursoContextoResponse contexto(Integer id) {
        var request = RequestContextHolder.getRequestAttributes();
        String key = CursoPortalService.class.getName() + ".contexto." + id;
        if (request != null && request.getAttribute(key, RequestAttributes.SCOPE_REQUEST) instanceof CursoContextoResponse cached) {
            return cached;
        }
        var context = consultar(() -> academic.contextoCurso(id));
        if (request != null) request.setAttribute(key, context, RequestAttributes.SCOPE_REQUEST);
        return context;
    }
    public CursoPortalResponse crear(CursoPortalRequest request) { return consultar(() -> academic.crearCurso(request)); }
    public CursoPortalResponse actualizar(Integer id, CursoPortalRequest request) { return consultar(() -> academic.actualizarCurso(id, request)); }
    public CursoPortalResponse estado(Integer id, boolean activo) { return consultar(() -> academic.estadoCurso(id, activo)); }
    public void asignarDocente(Integer id, Integer run) { consultar(() -> { academic.asignarDocente(id, run); return null; }); }
    public void quitarDocente(Integer id, Integer run) { consultar(() -> { academic.quitarDocente(id, run); return null; }); }
    public List<IdentityClient.UsuarioRef> participantes(Integer id, Authentication auth) { return consultar(() -> academic.participantes(id)); }
    public List<IdentityClient.PersonaPublicaRef> lista(Integer id, Authentication auth) { return consultar(() -> academic.lista(id)); }
    public void validarAcceso(Integer id, Authentication auth) { contexto(id); }
    public void validarAcceso(Integer id, IdentityClient.UsuarioRef user, Authentication auth) { contexto(id); }

    public List<Integer> cursosActuales(IdentityClient.UsuarioRef user) {
        if (!Boolean.TRUE.equals(user.activo())) return List.of();
        boolean profesor = "PROFESOR".equalsIgnoreCase(user.rol());
        boolean estudiante = "ESTUDIANTE".equalsIgnoreCase(user.rol()) && user.seccion() != null;
        if (!profesor && !estudiante) return List.of();
        return consultar(academic::listarCursos).stream()
                .filter(c -> profesor || (Boolean.TRUE.equals(c.activo()) && user.seccion().id().equals(c.idSeccion())))
                .map(CursoPortalResponse::id).toList();
    }

    static <T> T consultar(Supplier<T> call) {
        try { return call.get(); }
        catch (FeignException ex) {
            int status = ex.status();
            if (status == 401) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Inicia sesión para continuar.");
            if (status == 403) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este curso");
            if (status == 404) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe el recurso académico");
            if (status == 410) throw new ResponseStatusException(HttpStatus.GONE, "La configuración de aulas fue reemplazada por secciones y asignaturas automáticas");
            if (status == 400 || status == 409) throw new ResponseStatusException(HttpStatus.valueOf(status),
                    "Revisa los datos de la sección o asignatura");
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "No se pudo consultar ms-academic. Intenta nuevamente.", ex);
        }
    }
}
