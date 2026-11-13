package com.practika.ms_grading.controller;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_grading.dto.*;
import com.practika.ms_grading.model.*;
import com.practika.ms_grading.repository.*;
import com.practika.ms_grading.service.CrossServiceValidator;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/grading") @RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class GradingController {
    private final RespuestaRepository respuestas;
    private final RespuestaOpcionRepository respuestasOpciones;
    private final ObservacionPedagogicaRepository observaciones;
    private final CrossServiceValidator crossServiceValidator;
    private final EstadoRevisionRepository estadosRevision;
    private final com.practika.ms_grading.service.EntregaService entregaService;

    @GetMapping("/catalogos/estados-revision")
    public List<EstadoRevision> listarEstadosRevision() { return estadosRevision.findAllByOrderByIdAsc(); }

    @GetMapping("/respuestas")
    public List<Respuesta> listarRespuestas(@RequestParam(required=false) Integer runEstudiante,
            @RequestParam(required=false) Integer idPregunta, Authentication authentication) {
        if(runEstudiante!=null && idPregunta!=null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Filtre por RUN o pregunta, no por ambos");
        if(runEstudiante!=null) exigirPropietarioOStaff(runEstudiante,authentication); else exigirStaff(authentication);
        return entregaService.respuestasVisibles(runEstudiante,idPregunta,authentication);
    }
    @GetMapping("/respuestas/{id}") public Respuesta obtenerRespuesta(@PathVariable Integer id,Authentication authentication) {
        Respuesta r=respuesta(id); exigirPropietarioOStaff(r.getRunEstudiante(),authentication);
        entregaService.validarAccesoRespuesta(r,authentication); return r;
    }
    @GetMapping("/respuestas/{id}/opciones")
    public List<Integer> obtenerOpciones(@PathVariable Integer id,Authentication authentication) {
        Respuesta r=respuesta(id); exigirPropietarioOStaff(r.getRunEstudiante(),authentication);
        entregaService.validarAccesoRespuesta(r,authentication);
        return respuestasOpciones.findById_IdRespuesta(id).stream().map(ro->ro.getId().getIdOpcion()).toList();
    }

    @PostMapping("/respuestas")
    public void rechazarRespuestaIndividual() {
        throw new ResponseStatusException(HttpStatus.GONE,
                "Las respuestas se envían juntas mediante POST /api/v1/grading/entregas");
    }

    @PatchMapping("/respuestas/{id}/revision") @PreAuthorize("hasRole('PROFESOR')") @Transactional
    public Respuesta revisarRespuesta(@PathVariable Integer id,@Valid @RequestBody RevisionRequest dto, Authentication authentication) {
        return entregaService.revisar(id, dto, authentication);
    }

    @GetMapping("/observaciones")
    public List<ObservacionPedagogica> listarObservaciones(@RequestParam(required=false) Integer runEstudiante,
            @RequestParam(required=false) Integer idActividad, @RequestParam(required=false) Integer idCursoPortal, Authentication authentication) {
        if(runEstudiante!=null && idActividad!=null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Filtre por RUN o actividad, no por ambos");
        if(runEstudiante!=null) exigirPropietarioOStaff(runEstudiante,authentication); else exigirStaff(authentication);
        var vinculos = idCursoPortal == null ? null : crossServiceValidator.vinculos(idCursoPortal);
        java.util.List<Integer> cursos = null;
        if (esStaff(authentication)) {
            if (idCursoPortal == null) cursos = crossServiceValidator.cursosVisibles();
            else {
                crossServiceValidator.validarAccesoCursoPortal(idCursoPortal);
                cursos = vinculos;
            }
        }
        var visibles=esStaff(authentication)?observaciones.findByIdCursoPortalIn(cursos)
                :observaciones.findByRunEstudiante(Integer.valueOf(authentication.getName()));
        return visibles.stream().filter(o->runEstudiante==null||runEstudiante.equals(o.getRunEstudiante()))
                .filter(o->idActividad==null||idActividad.equals(o.getIdActividad()))
                .filter(o->vinculos==null||vinculos.contains(o.getIdCursoPortal())).toList();
    }
    @GetMapping("/observaciones/{id}") public ObservacionPedagogica obtenerObservacion(@PathVariable Integer id,Authentication authentication) {
        ObservacionPedagogica o=observacion(id); exigirPropietarioOStaff(o.getRunEstudiante(),authentication);
        if (esStaff(authentication)) crossServiceValidator.validarAccesoCursoPortal(o.getIdCursoPortal());
        return o;
    }
    @PostMapping("/observaciones") @PreAuthorize("hasRole('PROFESOR')") @ResponseStatus(HttpStatus.CREATED)
    public ObservacionPedagogica crearObservacion(@Valid @RequestBody ObservacionRequest dto, Authentication authentication) {
        crossServiceValidator.validarObservacion(dto, authentication);
        ObservacionPedagogica o=new ObservacionPedagogica(); aplicar(o,dto); return observaciones.save(o);
    }
    @PutMapping("/observaciones/{id}") @PreAuthorize("hasRole('PROFESOR')") public ObservacionPedagogica actualizarObservacion(@PathVariable Integer id,@Valid @RequestBody ObservacionRequest dto, Authentication authentication) {
        ObservacionPedagogica o=observacion(id);
        crossServiceValidator.validarAccesoCursoPortal(o.getIdCursoPortal());
        if (!o.getIdCursoPortal().equals(dto.idCursoPortal()) || !o.getRunEstudiante().equals(dto.runEstudiante()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"La observación debe conservar el curso y estudiante originales");
        crossServiceValidator.validarObservacion(dto, authentication);
        aplicar(o,dto); return observaciones.save(o);
    }
    @DeleteMapping("/observaciones/{id}") @PreAuthorize("hasRole('PROFESOR')") @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarObservacion(@PathVariable Integer id) { ObservacionPedagogica o=observacion(id); crossServiceValidator.validarAccesoCursoPortal(o.getIdCursoPortal()); observaciones.delete(o); }

    private void aplicar(ObservacionPedagogica o,ObservacionRequest d) {
        o.setIdCursoPortal(d.idCursoPortal()); o.setIdActividad(d.idActividad()); o.setIdPrueba(d.idPrueba());
        o.setRunEstudiante(d.runEstudiante()); o.setTexto(d.texto().trim()); o.setPorcentajeLogro(d.porcentajeLogro());
    }
    private EstadoRevision buscarEstadoRevision(String codigo) { return estadosRevision.findByCodigoIgnoreCase(codigo).orElseThrow(()->new ResponseStatusException(HttpStatus.BAD_REQUEST,"Estado de revisión no configurado")); }
    private Respuesta respuesta(Integer id) { return respuestas.findById(id).orElseThrow(()->noEncontrado("respuesta",id)); }
    private List<Respuesta> permitidas(List<Respuesta> valores, Authentication auth) {
        return valores.stream().filter(r -> {
            try { entregaService.validarAccesoRespuesta(r,auth); return true; }
            catch (ResponseStatusException ex) { if (ex.getStatusCode().value()==403 || ex.getStatusCode().value()==400) return false; throw ex; }
        }).toList();
    }
    private ObservacionPedagogica observacion(Integer id) { return observaciones.findById(id).orElseThrow(()->noEncontrado("observación",id)); }
    private ResponseStatusException noEncontrado(String tipo,Integer id) { return new ResponseStatusException(HttpStatus.NOT_FOUND,"No existe "+tipo+" con ID "+id); }
    private boolean esStaff(Authentication authentication) {
        return authentication.getAuthorities().stream().anyMatch(a->a.getAuthority().equals("ROLE_PROFESOR"));
    }
    private void exigirStaff(Authentication authentication) {
        if(!esStaff(authentication)) throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Acceso reservado a docentes");
    }
    private void exigirPropietarioOStaff(Integer run,Authentication authentication) {
        if(!esStaff(authentication) && !authentication.getName().equals(run.toString()))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Solo puedes consultar tus propios registros");
    }
}
