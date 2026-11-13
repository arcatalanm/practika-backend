package com.practika.ms_content.service;

import com.practika.ms_content.model.TipoEvaluacion;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.*;
import com.practika.ms_content.model.Opcion;
import com.practika.ms_content.model.Pregunta;
import com.practika.ms_content.repository.*;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class PreguntaService {
    private final PreguntaRepository preguntas;
    private final OpcionRepository opciones;
    private final TipoPreguntaRepository tipos;
    private final EvaluacionGateway evaluaciones;
    private final UnidadAccessService acceso;
    private final MaterialRepository materiales;

    public List<PreguntaResponse> listar(Integer idActividad, Integer idPrueba, Authentication auth) {
        if (idActividad != null && idPrueba != null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Indique actividad o prueba, no ambos");
        }
        List<Pregunta> encontradas;
        if (idActividad != null) {
            validarAcceso(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, idActividad), auth);
            encontradas = preguntas.findByIdActividad(idActividad);
        } else if (idPrueba != null) {
            validarAcceso(new EvaluacionRef(TipoEvaluacion.PRUEBA, idPrueba), auth);
            encontradas = preguntas.findByIdPrueba(idPrueba);
        } else {
            if (!acceso.tieneRol(auth, "UTP", "PROFESOR")) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Indica la actividad o prueba asignada que quieres consultar");
            }
            encontradas = preguntas.findAll();
        }
        return encontradas.stream().map(PreguntaResponse::from).toList();
    }

    public PreguntaResponse obtener(Integer id, Authentication auth) {
        Pregunta pregunta = buscar(id);
        validarAcceso(EvaluacionRef.dePregunta(pregunta), auth);
        return PreguntaResponse.from(pregunta);
    }

    @Transactional
    public PreguntaResponse crear(PreguntaRequest dto) {
        Pregunta pregunta = new Pregunta();
        aplicar(pregunta, dto);
        if (dto.opciones() != null) {
            PreguntaOpcionesValidator.validar(pregunta.getTipo(), dto.opciones(), Set.of());
        }
        pregunta = preguntas.save(pregunta);
        return dto.opciones() == null ? PreguntaResponse.from(pregunta)
                : guardarOpciones(pregunta, dto.opciones(), List.of());
    }

    @Transactional
    public PreguntaResponse actualizar(Integer id, PreguntaRequest dto) {
        Pregunta pregunta = buscar(id);
        aplicar(pregunta, dto);
        if (dto.opciones() == null) {
            return PreguntaResponse.from(preguntas.save(pregunta));
        }
        List<Opcion> existentes = opciones.findByIdPregunta(id);
        Set<Integer> idsExistentes = existentes.stream().map(Opcion::getId).collect(Collectors.toSet());
        PreguntaOpcionesValidator.validar(pregunta.getTipo(), dto.opciones(), idsExistentes);
        pregunta = preguntas.save(pregunta);
        return guardarOpciones(pregunta, dto.opciones(), existentes);
    }

    @Transactional
    public void eliminar(Integer id) {
        preguntas.delete(buscar(id));
    }

    public List<OpcionResponse> listarOpciones(Integer id, Authentication auth) {
        Pregunta pregunta = buscar(id);
        validarAcceso(EvaluacionRef.dePregunta(pregunta), auth);
        boolean staff = acceso.tieneRol(auth, "PROFESOR", "UTP");
        return opciones.findByIdPregunta(id).stream()
                .map(o -> new OpcionResponse(o.getId(), o.getTexto(), staff ? o.getEsCorrecta() : null)).toList();
    }

    @Transactional
    public OpcionEdicionResponse crearOpcion(Integer id, OpcionRequest dto) {
        buscar(id);
        Opcion opcion = new Opcion();
        opcion.setIdPregunta(id);
        aplicar(opcion, dto);
        return OpcionEdicionResponse.from(opciones.save(opcion));
    }

    @Transactional
    public OpcionEdicionResponse actualizarOpcion(Integer id, OpcionRequest dto) {
        Opcion opcion = opcion(id);
        aplicar(opcion, dto);
        return OpcionEdicionResponse.from(opciones.save(opcion));
    }

    @Transactional
    public void eliminarOpcion(Integer id) {
        opciones.delete(opcion(id));
    }

    public List<PreguntaResponse> listarDeEvaluacion(EvaluacionRef ref, Authentication auth) {
        var encontradas = listar(ref.tipo() == TipoEvaluacion.ACTIVIDAD ? ref.id() : null,
                ref.tipo() == TipoEvaluacion.PRUEBA ? ref.id() : null, auth);
        boolean staff = acceso.tieneRol(auth, "UTP", "PROFESOR");
        return encontradas.stream().map(p -> new PreguntaResponse(p.id(), p.idActividad(), p.idPrueba(),
                p.texto(), p.tipo(), p.puntajeMaximo(), opciones.findByIdPregunta(p.id()).stream()
                        .map(o -> new OpcionResponse(o.getId(), o.getTexto(), staff ? o.getEsCorrecta() : null))
                        .toList(), materiales.findByIdPreguntaOrderByIdAsc(p.id()).stream()
                                .filter(m -> staff || Boolean.TRUE.equals(m.getActivo()))
                                .map(MaterialResponse::from).toList())).toList();
    }

    @Transactional
    public PreguntaResponse crearEnEvaluacion(EvaluacionRef ref, PreguntaEnEvaluacionRequest dto) {
        return crear(dto.enEvaluacion(ref));
    }

    @Transactional
    public PreguntaResponse actualizarEnEvaluacion(EvaluacionRef ref, Integer id, PreguntaEnEvaluacionRequest dto) {
        validarPertenencia(ref, id);
        return actualizar(id, dto.enEvaluacion(ref));
    }

    @Transactional
    public void eliminarEnEvaluacion(EvaluacionRef ref, Integer id) {
        validarPertenencia(ref, id);
        eliminar(id);
    }

    private void validarPertenencia(EvaluacionRef ref, Integer id) {
        if (!ref.equals(EvaluacionRef.dePregunta(buscar(id)))) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "La pregunta no pertenece a esta evaluación");
        }
    }

    private void aplicar(Pregunta pregunta, PreguntaRequest dto) {
        if ((dto.idActividad() != null) == (dto.idPrueba() != null)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La pregunta debe pertenecer a una actividad o a una prueba");
        }
        EvaluacionRef ref = dto.idActividad() != null
                ? new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, dto.idActividad())
                : new EvaluacionRef(TipoEvaluacion.PRUEBA, dto.idPrueba());
        var evaluacion = evaluaciones.buscar(ref);
        var tipo = tipos.findByCodigoIgnoreCaseAndActivoTrue(dto.tipo().trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Tipo de pregunta inexistente o inactivo"));
        pregunta.setEvaluacion(evaluacion);
        pregunta.setTexto(dto.texto().trim());
        pregunta.setTipoPregunta(tipo);
        pregunta.setPuntajeMaximo(dto.puntajeMaximo());
    }

    private void aplicar(Opcion opcion, OpcionRequest dto) {
        opcion.setTexto(dto.texto().trim());
        opcion.setEsCorrecta(Boolean.TRUE.equals(dto.esCorrecta()));
    }

    private PreguntaResponse guardarOpciones(Pregunta pregunta, List<PreguntaOpcionRequest> recibidas,
            List<Opcion> existentes) {
        Map<Integer, Opcion> porId = existentes.stream()
                .collect(Collectors.toMap(Opcion::getId, Function.identity()));
        Set<Integer> conservadas = recibidas.stream().map(PreguntaOpcionRequest::id)
                .filter(java.util.Objects::nonNull).collect(Collectors.toSet());
        List<Opcion> actualizadas = recibidas.stream().map(dto -> {
            Opcion opcion = dto.id() == null ? new Opcion() : porId.get(dto.id());
            opcion.setIdPregunta(pregunta.getId());
            opcion.setTexto(dto.texto().trim());
            opcion.setEsCorrecta(dto.esCorrecta());
            return opcion;
        }).toList();
        opciones.deleteAll(existentes.stream().filter(o -> !conservadas.contains(o.getId())).toList());
        List<OpcionResponse> guardadas = opciones.saveAll(actualizadas).stream()
                .map(o -> new OpcionResponse(o.getId(), o.getTexto(), o.getEsCorrecta())).toList();
        return PreguntaResponse.conOpciones(pregunta, guardadas);
    }

    private void validarAcceso(EvaluacionRef ref, Authentication auth) {
        acceso.validarAcceso(evaluaciones.obtener(ref).idUnidad(), auth);
    }

    private Pregunta buscar(Integer id) {
        return preguntas.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe pregunta con ID " + id));
    }

    private Opcion opcion(Integer id) {
        return opciones.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe opción con ID " + id));
    }
}
