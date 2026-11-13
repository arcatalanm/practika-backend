package com.practika.ms_auth.service;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.practika.ms_auth.model.*;
import com.practika.ms_auth.repository.MatriculaRepository;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class MatriculaService {
    private final MatriculaRepository matriculas;
    private final com.practika.ms_auth.repository.UsuarioRepository usuarios;
    private final com.practika.ms_auth.repository.SeccionRepository secciones;

    @Transactional
    public List<Matricula> matricular(Integer run,Integer idSeccion) {
        var usuario=usuarios.findForUpdate(run).orElseThrow(()->new com.practika.ms_auth.exception.ResourceNotFoundException("No existe el estudiante"));
        if(!"ESTUDIANTE".equals(usuario.getRol().getCodigo())||!Boolean.TRUE.equals(usuario.getActivo()))
            throw new com.practika.ms_auth.exception.BadRequestException("Se necesita una cuenta de estudiante activa");
        var seccion=secciones.findById(idSeccion).map(Seccion::actual).filter(s->Boolean.TRUE.equals(s.getActivo()))
                .orElseThrow(()->new com.practika.ms_auth.exception.BadRequestException("La sección no existe o está inactiva"));
        usuario.setSeccion(seccion);sincronizar(usuario);return historial(run);
    }
    @Transactional
    public void cerrarVigente(Integer run) {
        var usuario=usuarios.findForUpdate(run).orElseThrow(()->new com.practika.ms_auth.exception.ResourceNotFoundException("No existe el estudiante"));
        if(!"ESTUDIANTE".equals(usuario.getRol().getCodigo()))
            throw new com.practika.ms_auth.exception.BadRequestException("La matrícula corresponde a una cuenta de estudiante");
        usuario.setSeccion(null);sincronizar(usuario);
    }

    /** Caller holds the student's user-row lock; never overwrite or delete past enrollments. */
    @Transactional
    public void sincronizar(Usuario usuario) {
        boolean estudiante=usuario.getRol()!=null && "ESTUDIANTE".equals(usuario.getRol().getCodigo());
        Integer destino=estudiante && usuario.getSeccion()!=null ? usuario.getSeccion().getId() : null;
        var vigentes=matriculas.findByRunEstudianteAndActivaTrue(usuario.getRun());
        if(vigentes.size()==1 && destino!=null && destino.equals(vigentes.getFirst().getSeccion().getId())) return;
        var ahora=LocalDateTime.now();
        for(var previa:vigentes) { previa.setActiva(false);previa.setFechaFin(ahora); }
        matriculas.saveAllAndFlush(vigentes);
        if(destino!=null) {
            var nueva=new Matricula();nueva.setRunEstudiante(usuario.getRun());nueva.setSeccion(usuario.getSeccion());
            nueva.setFechaInicio(ahora);matriculas.save(nueva);
        }
    }
    @Transactional(readOnly=true)
    public List<Matricula> historial(Integer run) { return matriculas.findByRunEstudianteOrderByFechaInicioDesc(run); }
    @Transactional(readOnly=true)
    public boolean pertenece(Integer run,Integer seccion,boolean soloActivas) {
        seccion = secciones.findById(seccion).orElseThrow().actual().getId();
        return soloActivas ? matriculas.existsByRunEstudianteAndSeccion_IdAndActivaTrue(run,seccion)
                : matriculas.existsByRunEstudianteAndSeccion_Id(run,seccion);
    }
    @Transactional(readOnly=true)
    public List<Usuario> participantes(Integer seccion,boolean historicas) { return matriculas.participantes(secciones.findById(seccion).orElseThrow().actual().getId(),historicas); }
}
