package com.practika.ms_content.config;
import org.springframework.context.annotation.*;
import org.springframework.boot.ApplicationRunner;
import com.practika.ms_content.service.EvaluacionPublicadaService;
@Configuration
public class PublicacionesInicialesConfig {
    @Bean ApplicationRunner publicarAsignacionesExistentes(EvaluacionPublicadaService service) {
        return args->service.inicializarExistentes();
    }
}
