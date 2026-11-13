package com.practika.ms_academic.service;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_academic.dto.*;
import com.practika.ms_academic.model.Asignatura;
import com.practika.ms_academic.model.ObjetivoAprendizaje;
import com.practika.ms_academic.repository.AsignaturaRepository;
import com.practika.ms_academic.repository.ObjetivoAprendizajeRepository;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class AcademicService {
    private final AsignaturaRepository asignaturas;
    private final ObjetivoAprendizajeRepository objetivos;

    public List<AsignaturaResponse> listarAsignaturas() {
        return asignaturas.findAll().stream().map(AsignaturaResponse::from).toList();
    }

    public AsignaturaResponse obtenerAsignatura(Integer id) {
        return AsignaturaResponse.from(asignatura(id));
    }

    @Transactional
    public AsignaturaResponse crearAsignatura(AsignaturaRequest dto) {
        Asignatura asignatura = new Asignatura();
        asignatura.setNombre(dto.nombre().trim());
        return AsignaturaResponse.from(asignaturas.save(asignatura));
    }

    @Transactional
    public AsignaturaResponse actualizarAsignatura(Integer id, AsignaturaRequest dto) {
        Asignatura asignatura = asignatura(id);
        asignatura.setNombre(dto.nombre().trim());
        return AsignaturaResponse.from(asignaturas.save(asignatura));
    }

    @Transactional
    public AsignaturaResponse cambiarEstadoAsignatura(Integer id, boolean activo) {
        Asignatura asignatura = asignatura(id);
        asignatura.setActivo(activo);
        return AsignaturaResponse.from(asignaturas.save(asignatura));
    }

    public List<ObjetivoResponse> listarObjetivos(Integer idAsignatura) {
        var encontrados = idAsignatura == null ? objetivos.findAll() : objetivos.findByAsignaturaId(idAsignatura);
        return encontrados.stream().map(ObjetivoResponse::from).toList();
    }

    public ObjetivoResponse obtenerObjetivo(Integer id) {
        return ObjetivoResponse.from(objetivo(id));
    }

    public List<ObjetivoResponse> objetivosDeAsignatura(Integer id) {
        asignatura(id);
        return objetivos.findByAsignaturaId(id).stream().map(ObjetivoResponse::from).toList();
    }

    @Transactional
    public ObjetivoResponse crearObjetivo(ObjetivoRequest dto) {
        ObjetivoAprendizaje objetivo = new ObjetivoAprendizaje();
        aplicar(objetivo, dto);
        return ObjetivoResponse.from(objetivos.save(objetivo));
    }

    @Transactional
    public ObjetivoResponse actualizarObjetivo(Integer id, ObjetivoRequest dto) {
        ObjetivoAprendizaje objetivo = objetivo(id);
        aplicar(objetivo, dto);
        return ObjetivoResponse.from(objetivos.save(objetivo));
    }

    @Transactional
    public void eliminarObjetivo(Integer id) {
        objetivos.delete(objetivo(id));
    }

    private void aplicar(ObjetivoAprendizaje objetivo, ObjetivoRequest dto) {
        Asignatura asignatura = asignatura(dto.idAsignatura());
        if (Boolean.FALSE.equals(asignatura.getActivo())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La asignatura está inactiva");
        }
        String codigo = dto.codigo().trim().toUpperCase(java.util.Locale.ROOT);
        if (objetivos.findByCodigoIgnoreCase(codigo).filter(o -> !o.getId().equals(objetivo.getId())).isPresent())
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe ese código de objetivo de aprendizaje");
        objetivo.setCodigo(codigo);
        objetivo.setAsignatura(asignatura);
        objetivo.setDescripcion(dto.descripcion().trim());
    }

    private Asignatura asignatura(Integer id) {
        return asignaturas.findById(id).orElseThrow(() -> noEncontrado("asignatura", id));
    }

    private ObjetivoAprendizaje objetivo(Integer id) {
        return objetivos.findById(id).orElseThrow(() -> noEncontrado("objetivo", id));
    }

    private ResponseStatusException noEncontrado(String tipo, Integer id) {
        return new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe " + tipo + " con ID " + id);
    }
}
