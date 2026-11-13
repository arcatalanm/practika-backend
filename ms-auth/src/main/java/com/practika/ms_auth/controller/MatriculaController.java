package com.practika.ms_auth.controller;

import java.util.List;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import com.practika.ms_auth.model.Matricula;
import com.practika.ms_auth.service.MatriculaService;
import lombok.RequiredArgsConstructor;

@RestController @RequestMapping("/api/v1/auth") @RequiredArgsConstructor
public class MatriculaController {
    private final MatriculaService matriculas;
    public record MatriculaRequest(@jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Positive Integer idSeccion) {}
    @PostMapping("/usuarios/{run}/matriculas")
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public List<Matricula> matricular(@PathVariable Integer run,@jakarta.validation.Valid @RequestBody MatriculaRequest request) {
        return matriculas.matricular(run,request.idSeccion());
    }
    @PatchMapping("/usuarios/{run}/matricula-vigente/cerrar")
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cerrar(@PathVariable Integer run){matriculas.cerrarVigente(run);}
    @GetMapping("/usuarios/{run}/matriculas")
    public List<Matricula> historial(@PathVariable Integer run,Authentication auth) {
        autorizar(run,auth);return matriculas.historial(run);
    }
    @GetMapping("/secciones/{id}/matriculas/{run}")
    public boolean pertenece(@PathVariable Integer id,@PathVariable Integer run,
            @RequestParam(defaultValue="false") boolean soloActivas,Authentication auth) {
        autorizar(run,auth);return matriculas.pertenece(run,id,soloActivas);
    }
    private void autorizar(Integer run,Authentication auth) {
        if(!auth.getName().equals(run.toString()) && auth.getAuthorities().stream().noneMatch(a->
                List.of("ROLE_ADMIN","ROLE_UTP","ROLE_PROFESOR").contains(a.getAuthority())))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Solo puedes consultar tu propio historial de matrículas");
    }
}
