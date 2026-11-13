package com.practika.ms_content.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.client.AcademicClient;
import feign.FeignException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CrossServiceValidator {
    private final AcademicClient academicClient;

    public void validarUnidad(Integer idAsignatura, Integer idObjetivo) {
        AcademicClient.AsignaturaRef asignatura = consultar(
                () -> academicClient.obtenerAsignatura(idAsignatura), "No existe la asignatura indicada");
        if (Boolean.FALSE.equals(asignatura.activo())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La asignatura está inactiva");
        }
        AcademicClient.ObjetivoRef objetivo = consultar(
                () -> academicClient.obtenerObjetivo(idObjetivo), "No existe el objetivo de aprendizaje indicado");
        if (objetivo.asignatura() == null || !idAsignatura.equals(objetivo.asignatura().id())
                || !asignatura.id().equals(objetivo.asignatura().id())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El objetivo debe pertenecer a la asignatura de la unidad");
        }
    }

    private <T> T consultar(java.util.function.Supplier<T> request, String notFoundMessage) {
        try {
            return request.get();
        } catch (FeignException ex) {
            if (ex.status() == 404) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, notFoundMessage);
            if (ex.status() == 401) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                    "Inicia sesión para continuar.");
            if (ex.status() == 403) throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No tienes permisos para validar la referencia relacionada");
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY,
                    "No se pudo consultar un servicio relacionado", ex);
        }
    }
}
