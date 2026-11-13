package com.practika.ms_auth.service;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import com.practika.ms_auth.dto.UsuarioResponseDTO;
import com.practika.ms_auth.exception.*;
import com.practika.ms_auth.mapper.UsuarioMapper;
import com.practika.ms_auth.model.FotoPerfil;
import com.practika.ms_auth.repository.*;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class FotoPerfilService {
    private final FotoPerfilRepository fotos;
    private final UsuarioRepository usuarios;

    @Transactional
    public UsuarioResponseDTO guardar(Integer run, MultipartFile archivo) {
        if (archivo.isEmpty() || archivo.getSize() > 5 * 1024 * 1024)
            throw new BadRequestException("Selecciona una imagen JPG o PNG de hasta 5 MB");
        byte[] jpeg;
        try (var input = ImageIO.createImageInputStream(archivo.getInputStream())) {
            var readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) throw new BadRequestException("El archivo no es una imagen JPG o PNG válida");
            var reader = readers.next();
            try {
                reader.setInput(input);
                String format = reader.getFormatName();
                if (!(format.equalsIgnoreCase("jpeg") || format.equalsIgnoreCase("png"))
                        || (long) reader.getWidth(0) * reader.getHeight(0) > 25_000_000)
                    throw new BadRequestException("Usa una imagen JPG o PNG de hasta 25 megapíxeles");
                BufferedImage source = reader.read(0);
                double scale = Math.min(1d, 1024d / Math.max(source.getWidth(), source.getHeight()));
                var result = new BufferedImage(Math.max(1, (int)(source.getWidth()*scale)), Math.max(1, (int)(source.getHeight()*scale)), BufferedImage.TYPE_INT_RGB);
                Graphics2D graphics = result.createGraphics();
                try { graphics.setColor(Color.WHITE); graphics.fillRect(0,0,result.getWidth(),result.getHeight()); graphics.drawImage(source,0,0,result.getWidth(),result.getHeight(),null); }
                finally { graphics.dispose(); }
                var output = new ByteArrayOutputStream();
                ImageIO.write(result,"jpeg",output); jpeg = output.toByteArray();
            } finally { reader.dispose(); }
        } catch (IOException ex) { throw new BadRequestException("No se pudo leer la imagen"); }
        var usuario = usuarios.findById(run).orElseThrow(() -> new ResourceNotFoundException("No existe la cuenta"));
        FotoPerfil foto = new FotoPerfil(); foto.setRun(run); foto.setContenido(jpeg); fotos.save(foto);
        usuario.setImgPerfil("/api/v1/auth/usuarios/" + run + "/foto?v=" + java.util.UUID.randomUUID());
        return UsuarioMapper.toResponseDTO(usuarios.save(usuario));
    }

    @Transactional(readOnly=true)
    public byte[] obtener(Integer run) {
        return fotos.findById(run).orElseThrow(() -> new ResourceNotFoundException("La cuenta no tiene foto")).getContenido();
    }
}
