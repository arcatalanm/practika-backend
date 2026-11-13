package com.practika.ms_content.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.practika.ms_content.dto.ContentCapabilities;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

@RestController
@RequestMapping("/api/v1/content")
@SecurityRequirement(name = "bearerAuth")
public class CapacidadesController {
    @GetMapping("/capacidades")
    public ContentCapabilities capacidades() {
        return new ContentCapabilities(true, true);
    }
}
