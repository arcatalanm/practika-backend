package com.practika.ms_academic.service;

import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_academic.client.IdentityClient;
import com.practika.ms_academic.model.*;
import com.practika.ms_academic.repository.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class DocenteVariasAsignaturasTest {
    private final CursoPortalRepository cursos = mock(CursoPortalRepository.class);
    private final IdentityClient identity = mock(IdentityClient.class);
    private final AsignaturaRepository asignaturas = mock(AsignaturaRepository.class);
    private final DocenteAsignaturaRepository materias = mock(DocenteAsignaturaRepository.class);
    private final CursoPortalService service = new CursoPortalService(cursos, identity, asignaturas, materias);
    private final IdentityClient.SeccionRef primero = new IdentityClient.SeccionRef(1, "Primero básico", true);
    private final IdentityClient.SeccionRef segundo = new IdentityClient.SeccionRef(2, "Segundo básico", true);
    private final Authentication auth = new UsernamePasswordAuthenticationToken("docente", "", List.of(new SimpleGrantedAuthority("ROLE_PROFESOR")));

    @BeforeEach void setup() {
        when(identity.obtenerUsuarioActual()).thenReturn(new IdentityClient.UsuarioRef(12345682, '3', "Carolina Vega", "PROFESOR", primero, true));
        when(identity.obtenerSeccion(1)).thenReturn(primero);
        when(identity.obtenerSeccion(2)).thenReturn(segundo);
        when(materias.findByRunProfesor(12345682)).thenReturn(List.of(materia(3, true), materia(5, true)));
    }

    private DocenteAsignatura materia(int subject, boolean both) {
        var value = new DocenteAsignatura(); value.setRunProfesor(12345682);
        value.setIdAsignatura(subject); value.setAmbosBasicos(both); return value;
    }

    private CursoPortal curso(int id, int subject, int section) {
        var value = new CursoPortal(); value.setId(id); value.setIdAsignatura(subject);
        value.setIdSeccion(section); value.setActivo(true);
        when(cursos.findById(id)).thenReturn(Optional.of(value)); return value;
    }

    @Test void puedeImpartirHistoriaYCienciasEnAmbosBasicos() {
        int id = 10;
        for (int subject : List.of(3, 5)) for (int section : List.of(1, 2)) {
            curso(id, subject, section); int current = id++;
            assertDoesNotThrow(() -> service.validarAcceso(current, auth));
        }
    }

    @Test void noObtienePermisoParaLasOtrasMaterias() {
        curso(20, 1, 1); curso(21, 2, 2);
        for (int id : List.of(20, 21)) {
            var failure = assertThrows(ResponseStatusException.class, () -> service.validarAcceso(id, auth));
            assertEquals(403, failure.getStatusCode().value());
        }
    }

    @Test void elPermisoEntreBasicosNoSeTransfiereAUnaAsignaturaDistinta() {
        when(materias.findByRunProfesor(12345682)).thenReturn(List.of(materia(3, false), materia(5, true)));
        curso(30, 3, 2); curso(31, 5, 2);
        assertThrows(ResponseStatusException.class, () -> service.validarAcceso(30, auth));
        assertDoesNotThrow(() -> service.validarAcceso(31, auth));
    }

    @Test void elCatalogoSoloIncluyeSusDosMateriasEnAmbasSecciones() {
        when(identity.obtenerSecciones()).thenReturn(List.of(primero, segundo));
        var subjects = List.of(subject(1, "Matemática"), subject(2, "Lenguaje"), subject(3, "Ciencias"), subject(5, "Historia"));
        when(asignaturas.bloquearCatalogo()).thenReturn(subjects);
        for (var subject : subjects) when(asignaturas.findById(subject.getId())).thenReturn(Optional.of(subject));
        var firstCourses = List.of(curso(41, 1, 1), curso(42, 2, 1), curso(43, 3, 1), curso(45, 5, 1));
        var secondCourses = List.of(curso(51, 1, 2), curso(52, 2, 2), curso(53, 3, 2), curso(55, 5, 2));
        when(cursos.findByIdSeccionAndPeriodoIsNullOrderByIdAsc(1)).thenReturn(firstCourses);
        when(cursos.findByIdSeccionAndPeriodoIsNullOrderByIdAsc(2)).thenReturn(secondCourses);
        assertEquals(List.of(3, 5, 3, 5), service.listar(auth).stream().map(c -> c.idAsignatura()).toList());
    }

    private Asignatura subject(int id, String name) {
        var value = new Asignatura(); value.setId(id); value.setNombre(name); value.setActivo(true); return value;
    }
}
