package com.practika.ms_content.service;

import java.io.IOException;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.dto.UnidadResponse;
import com.practika.ms_content.model.UnidadImagen;
import com.practika.ms_content.repository.UnidadImagenRepository;
import com.practika.ms_content.repository.UnidadRepository;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class UnidadImagenService {
    private static final int MAX_BYTES = 5 * 1024 * 1024;
    private final UnidadRepository unidades;
    private final UnidadImagenRepository imagenes;
    private final UnidadAccessService acceso;

    @Transactional
    public UnidadResponse guardar(Integer id, MultipartFile archivo) {
        var unidad = unidades.findById(id).orElseThrow(() -> error(HttpStatus.NOT_FOUND, "No existe la unidad"));
        if (archivo.isEmpty() || archivo.getSize() > MAX_BYTES)
            throw error(HttpStatus.BAD_REQUEST, "Selecciona una imagen JPG o PNG de hasta 5 MB");
        byte[] bytes;
        try (var in = archivo.getInputStream()) { bytes = in.readNBytes(MAX_BYTES + 1); }
        catch (IOException ex) { throw error(HttpStatus.BAD_REQUEST, "No se pudo leer la imagen"); }
        if (bytes.length > MAX_BYTES) throw error(HttpStatus.PAYLOAD_TOO_LARGE, "La imagen supera 5 MB");
        String tipo = detectar(bytes);
        var imagen = imagenes.findById(id).orElseGet(() -> { var nueva = new UnidadImagen(); nueva.setIdUnidad(id); return nueva; });
        imagen.setContenido(bytes); imagen.setTipoContenido(tipo); imagenes.save(imagen);
        unidad.setImgUnidad("/api/v1/content/unidades/" + id + "/imagen?v=" + UUID.randomUUID());
        return UnidadResponse.from(unidades.save(unidad));
    }

    @Transactional(readOnly = true)
    public UnidadImagen obtener(Integer id, Authentication auth) {
        acceso.validarAcceso(id, auth); // UTP/PROFESOR siempre; estudiante solo si la unidad está en su curso
        return imagenes.findById(id).orElseThrow(() -> error(HttpStatus.NOT_FOUND, "La unidad no tiene imagen"));
    }

    private String detectar(byte[] b) {
        if (b.length >= 8 && (b[0] & 0xff) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') return "image/png";
        if (b.length >= 3 && (b[0] & 0xff) == 0xff && (b[1] & 0xff) == 0xd8 && (b[2] & 0xff) == 0xff) return "image/jpeg";
        throw error(HttpStatus.BAD_REQUEST, "Usa una imagen JPG o PNG");
    }

    private ResponseStatusException error(HttpStatus status, String message) { return new ResponseStatusException(status, message); }
}
