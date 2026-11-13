package com.practika.ms_content.service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Stream;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.EvaluacionRequest;
import com.practika.ms_content.dto.EvaluacionEdicionRequest;
import com.practika.ms_content.model.*;
import com.practika.ms_content.repository.*;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class EvaluacionService implements EvaluacionGateway {
    private final ActividadRepository actividades;
    private final PruebaRepository pruebas;
    private final UnidadRepository unidades;
    private final EvaluacionAsignadaRepository publicaciones;
    private final UnidadAccessService acceso;
    private final EvaluacionRepository evaluaciones;

    public List<Evaluacion> listarPorTipo(TipoEvaluacion tipo) {
        return tipo == TipoEvaluacion.ACTIVIDAD ? List.copyOf(actividades.findAll()) : List.copyOf(pruebas.findAll());
    }

    public List<Evaluacion> listarDeUnidad(Integer idUnidad) {
        return evaluaciones.findByIdUnidadOrderByIdEvaluacionAsc(idUnidad);
    }

    public List<Evaluacion> listar(Integer idUnidad, Authentication auth) {
        List<Evaluacion> encontradas;
        if (idUnidad == null) {
            if (!acceso.tieneRol(auth, "UTP")) {
                throw error(HttpStatus.BAD_REQUEST, "Selecciona una unidad para consultar sus evaluaciones");
            }
            encontradas = Stream.concat(listarPorTipo(TipoEvaluacion.ACTIVIDAD).stream(),
                    listarPorTipo(TipoEvaluacion.PRUEBA).stream()).toList();
        } else {
            validarUnidad(idUnidad);
            acceso.validarAcceso(idUnidad, auth);
            encontradas = listarDeUnidad(idUnidad);
        }
        return encontradas.stream().sorted(Comparator.comparing(Evaluacion::getTitulo, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(Evaluacion::getTipoEvaluacion).thenComparing(Evaluacion::getId)).toList();
    }

    public Evaluacion buscar(EvaluacionRef ref) {
        return switch (ref.tipo()) {
            case ACTIVIDAD -> actividades.findById(ref.id()).orElseThrow(() -> noEncontrada(ref));
            case PRUEBA -> pruebas.findById(ref.id()).orElseThrow(() -> noEncontrada(ref));
        };
    }

    public Evaluacion buscarPorId(Integer id) {
        return evaluaciones.findById(id).orElseThrow(() -> error(HttpStatus.NOT_FOUND, "No existe la evaluación"));
    }

    public EvaluacionRef referencia(Integer id) {
        var evaluacion = buscarPorId(id);
        return new EvaluacionRef(evaluacion.getTipoEvaluacion(), evaluacion.getId());
    }

    public Evaluacion obtener(EvaluacionRef ref, Authentication auth) {
        var evaluacion = buscar(ref);
        acceso.validarAcceso(evaluacion.getIdUnidad(), auth);
        return evaluacion;
    }

    @Override
    public Datos obtener(EvaluacionRef ref) {
        var evaluacion = buscar(ref);
        return new Datos(ref, evaluacion.getIdUnidad(), evaluacion.getEstadoActivo());
    }

    @Transactional
    public Evaluacion crear(EvaluacionRequest dto) {
        validar(dto);
        Evaluacion evaluacion = dto.tipo() == TipoEvaluacion.ACTIVIDAD ? new Actividad() : new Prueba();
        aplicar(evaluacion, dto);
        return guardar(evaluacion);
    }

    @Transactional
    public Evaluacion actualizar(EvaluacionRef ref, EvaluacionRequest dto) {
        if (ref.tipo() != dto.tipo()) throw error(HttpStatus.BAD_REQUEST, "El tipo de evaluación no se puede cambiar");
        validar(dto);
        var evaluacion = buscar(ref);
        if (!evaluacion.getIdUnidad().equals(dto.idUnidad()) && publicada(ref)) {
            throw error(HttpStatus.CONFLICT, "Una evaluación publicada conserva su unidad; crea otra evaluación para cambiarla de unidad");
        }
        aplicar(evaluacion, dto);
        return guardar(evaluacion);
    }

    @Transactional
    public Evaluacion actualizarContenido(EvaluacionRef ref, EvaluacionEdicionRequest dto) {
        var evaluacion = buscar(ref);
        return actualizar(ref, new EvaluacionRequest(ref.tipo(), evaluacion.getIdUnidad(), dto.titulo(),
                dto.fechaAplicacion(), dto.estadoActivo(), dto.cantidadIntentos()));
    }

    @Transactional
    public Evaluacion cambiarEstado(EvaluacionRef ref, boolean activo) {
        var evaluacion = buscar(ref);
        evaluacion.setEstadoActivo(activo);
        return evaluacion;
    }

    @Transactional
    public void eliminar(EvaluacionRef ref) {
        Evaluacion evaluacion = switch (ref.tipo()) {
            case ACTIVIDAD -> actividades.findForUpdate(ref.id()).orElseThrow(() -> noEncontrada(ref));
            case PRUEBA -> pruebas.findForUpdate(ref.id()).orElseThrow(() -> noEncontrada(ref));
        };
        if (publicada(ref)) throw error(HttpStatus.CONFLICT, "Ya fue publicada; desactívala en lugar de eliminarla");
        if (evaluacion instanceof Actividad actividad) {
            actividades.delete(actividad);
            actividades.flush();
        } else {
            pruebas.delete((Prueba) evaluacion);
            pruebas.flush();
        }
    }

    private Evaluacion guardar(Evaluacion evaluacion) {
        return evaluacion instanceof Actividad actividad ? actividades.save(actividad) : pruebas.save((Prueba) evaluacion);
    }

    private boolean publicada(EvaluacionRef ref) {
        return ref.tipo() == TipoEvaluacion.ACTIVIDAD ? publicaciones.existsByIdActividad(ref.id()) : publicaciones.existsByIdPrueba(ref.id());
    }

    private void aplicar(Evaluacion evaluacion, EvaluacionRequest dto) {
        evaluacion.setIdUnidad(dto.idUnidad());
        evaluacion.setTitulo(dto.titulo().trim());
        evaluacion.setEstadoActivo(dto.estadoActivo() == null ? true : dto.estadoActivo());
        evaluacion.setCantidadIntentos(dto.cantidadIntentos() == null ? 1 : dto.cantidadIntentos());
        if (evaluacion instanceof Prueba prueba) prueba.setFechaAplicacion(dto.fechaAplicacion());
    }

    private void validar(EvaluacionRequest dto) {
        if (dto.tipo() == null) throw error(HttpStatus.BAD_REQUEST, "Indica el tipo de evaluación");
        if ((dto.tipo() == TipoEvaluacion.PRUEBA) != (dto.fechaAplicacion() != null)) {
            throw error(HttpStatus.BAD_REQUEST, "Las pruebas requieren fecha de aplicación; las actividades no llevan fecha");
        }
        validarUnidad(dto.idUnidad());
    }

    private void validarUnidad(Integer id) {
        unidades.findById(id).orElseThrow(() -> error(HttpStatus.NOT_FOUND, "No existe unidad con ID " + id));
    }

    private ResponseStatusException noEncontrada(EvaluacionRef ref) {
        return error(HttpStatus.NOT_FOUND, "No existe evaluación " + ref.tipo() + " con ID " + ref.id());
    }

    private ResponseStatusException error(HttpStatus status, String message) {
        return new ResponseStatusException(status, message);
    }
}
