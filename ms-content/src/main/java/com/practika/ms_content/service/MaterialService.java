package com.practika.ms_content.service;

import com.practika.ms_content.model.TipoEvaluacion;
import java.net.URI;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.MaterialRequest;
import com.practika.ms_content.dto.MaterialResponse;
import com.practika.ms_content.model.Material;
import com.practika.ms_content.model.Pregunta;
import com.practika.ms_content.model.TipoMaterial;
import com.practika.ms_content.repository.*;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class MaterialService {
    private final MaterialRepository materiales;
    private final TipoMaterialRepository tipos;
    private final PreguntaRepository preguntas;
    private final EvaluacionGateway evaluaciones;
    private final UnidadAccessService acceso;

    public List<MaterialResponse> listarDePregunta(Integer id, Authentication auth) {
        Pregunta pregunta = pregunta(id);
        validarAcceso(EvaluacionRef.dePregunta(pregunta), auth);
        return visibles(materiales.findByIdPreguntaOrderByIdAsc(id), auth);
    }

    public List<MaterialResponse> listarDeActividad(Integer id, Authentication auth) {
        validarAcceso(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id), auth);
        return visibles(materiales.findByIdActividad(id), auth);
    }

    @Transactional
    public MaterialResponse crearEnPregunta(Integer id, MaterialRequest dto) {
        pregunta(id);
        Material material = new Material();
        material.setIdPregunta(id);
        aplicar(material, dto);
        return MaterialResponse.from(materiales.save(material));
    }

    @Transactional
    public MaterialResponse crearEnActividad(Integer id, MaterialRequest dto) {
        var evaluacion = evaluaciones.buscar(new EvaluacionRef(TipoEvaluacion.ACTIVIDAD, id));
        Material material = new Material();
        material.setEvaluacion(evaluacion);
        aplicar(material, dto);
        return MaterialResponse.from(materiales.save(material));
    }

    @Transactional
    public MaterialResponse crearEnEvaluacion(Integer id, MaterialRequest dto) {
        Material material = new Material();
        material.setEvaluacion(evaluaciones.buscarPorId(id));
        aplicar(material, dto);
        return MaterialResponse.from(materiales.save(material));
    }

    public List<MaterialResponse> listarDeEvaluacion(Integer id, Authentication auth) {
        var evaluacion = evaluaciones.buscarPorId(id);
        acceso.validarAcceso(evaluacion.getIdUnidad(), auth);
        return visibles(materiales.findByEvaluacionIdEvaluacionOrderByIdAsc(id), auth);
    }

    @Transactional
    public MaterialResponse actualizar(Integer id, MaterialRequest dto) {
        Material material = buscar(id);
        aplicar(material, dto);
        return MaterialResponse.from(materiales.save(material));
    }

    @Transactional
    public MaterialResponse cambiarEstado(Integer id, boolean activo) {
        Material material = buscar(id);
        material.setActivo(activo);
        return MaterialResponse.from(materiales.save(material));
    }

    @Transactional
    public void eliminar(Integer id) {
        materiales.delete(buscar(id));
    }

    private List<MaterialResponse> visibles(List<Material> encontrados, Authentication auth) {
        return encontrados.stream()
                .filter(m -> acceso.tieneRol(auth, "UTP") || Boolean.TRUE.equals(m.getActivo()))
                .map(MaterialResponse::from).toList();
    }

    private void aplicar(Material material, MaterialRequest dto) {
        TipoMaterial tipo = tipos.findByCodigoIgnoreCaseAndActivoTrue(dto.tipo().trim())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Tipo de material inexistente o inactivo"));
        boolean lectura = "TEXTO".equalsIgnoreCase(tipo.getCodigo());
        String contenido = lectura ? dto.contenidoTexto() : dto.contenidoUrl();
        if (contenido == null || contenido.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    lectura ? "Escribe el contenido de la lectura" : "Ingresa la URL del material");
        }
        if (!lectura) {
            validarUrl(contenido.trim());
        }
        material.setTipoMaterial(tipo);
        material.setTitulo(dto.titulo() == null || dto.titulo().isBlank() ? null : dto.titulo().trim());
        material.setContenidoUrl(lectura ? null : contenido.trim());
        material.setContenidoTexto(lectura ? contenido.trim() : null);
    }

    private void validarUrl(String contenido) {
        try {
            URI uri = URI.create(contenido);
            boolean recursoServicio = contenido.matches(
                    "/api/v1/content/recursos/([a-zA-Z0-9_-]+\\.(svg|gif|png|jpg|mp3|mp4)|archivos/[a-f0-9-]{36})");
            if (!recursoServicio && (!("http".equalsIgnoreCase(uri.getScheme())
                    || "https".equalsIgnoreCase(uri.getScheme())) || uri.getHost() == null)) {
                throw new IllegalArgumentException();
            }
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La URL debe ser una dirección HTTP o HTTPS válida");
        }
    }

    private void validarAcceso(EvaluacionRef ref, Authentication auth) {
        acceso.validarAcceso(evaluaciones.obtener(ref).idUnidad(), auth);
    }

    private Pregunta pregunta(Integer id) {
        return preguntas.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe pregunta con ID " + id));
    }

    private Material buscar(Integer id) {
        return materiales.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe material con ID " + id));
    }
}
