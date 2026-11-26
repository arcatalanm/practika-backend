package com.practika.ms_content.service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import com.practika.ms_content.model.*;
import com.practika.ms_content.repository.*;
import lombok.RequiredArgsConstructor;

@Service @RequiredArgsConstructor
public class ArchivoRecursoService {
    private final ArchivoRecursoRepository archivos;
    private final PreguntaRepository preguntas;
    private final MaterialRepository materiales;
    private final TipoMaterialRepository tipos;
    private final EvaluacionService evaluaciones;
    private final UnidadAccessService acceso;
    private final com.practika.ms_content.storage.MediaStorage media;
    public static final int MAX_BYTES=25*1024*1024;

    @Transactional
    public Material subir(Integer idPregunta, MultipartFile file) {
        return subir(idPregunta,file,null);
    }

    @Transactional
    public Material subir(Integer idPregunta, MultipartFile file, String esperado) {
        preguntas.findById(idPregunta).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe la pregunta"));
        return guardar(idPregunta, null, file, esperado);
    }

    @Transactional
    public Material subirActividad(Integer idActividad, MultipartFile file) {
        throw error(HttpStatus.GONE,"Agrega el material dentro de una pregunta");
    }

    @Transactional
    public Material subirEvaluacion(Integer id, MultipartFile file) {
        throw error(HttpStatus.GONE,"Agrega el material dentro de una pregunta");
    }

    private Material guardar(Integer idPregunta, Evaluacion evaluacion, MultipartFile file, String esperado) {
        if(file.isEmpty() || file.getSize()>MAX_BYTES) throw error(HttpStatus.BAD_REQUEST,"Selecciona un archivo de hasta 25 MB");
        byte[] bytes;
        try(var input=file.getInputStream()) { bytes=input.readNBytes(MAX_BYTES+1); }
        catch(IOException ex) { throw error(HttpStatus.BAD_REQUEST,"No se pudo leer el archivo"); }
        if(bytes.length>MAX_BYTES) throw error(HttpStatus.PAYLOAD_TOO_LARGE,"El archivo supera 25 MB");
        var type=detectar(bytes);
        if (esperado != null && !type.codigo().equalsIgnoreCase(esperado))
            throw error(HttpStatus.BAD_REQUEST,"El archivo no corresponde al tipo de material elegido");
        String name=file.getOriginalFilename()==null ? "Recurso" : file.getOriginalFilename().replaceAll("[\\p{Cntrl}\\\\/]","_").trim();
        if(name.isBlank()) name="Recurso";
        name=name.substring(0,Math.min(name.length(),200));
        var archivo=new ArchivoRecurso(); archivo.setId(UUID.randomUUID().toString());archivo.setIdPregunta(idPregunta);archivo.setEvaluacion(evaluacion);
        archivo.setNombre(name);archivo.setTipoContenido(type.mime());archivo.setRutaArchivo(media.guardar(bytes, "recursos", type.mime()));archivos.save(archivo);
        var material=new Material();material.setIdPregunta(idPregunta);material.setEvaluacion(evaluacion);material.setTitulo(name);
        material.setTipoMaterial(tipos.findByCodigoIgnoreCaseAndActivoTrue(type.codigo()).orElseThrow(()->error(HttpStatus.CONFLICT,"El tipo de recurso no está configurado")));
        material.setContenidoUrl("/api/v1/content/recursos/archivos/"+archivo.getId());
        return materiales.save(material);
    }

    @Transactional(readOnly=true)
    public ArchivoRecurso obtener(String id, Authentication auth) {
        var archivo=archivos.findById(id).orElseThrow(()->error(HttpStatus.NOT_FOUND,"No existe el recurso"));
        var evaluacion = archivo.getEvaluacion() != null ? archivo.getEvaluacion()
                : preguntas.findById(archivo.getIdPregunta()).orElseThrow(() -> error(HttpStatus.NOT_FOUND, "No existe la pregunta")).getEvaluacion();
        Integer unidad = evaluacion.getIdUnidad();
        acceso.validarAcceso(unidad,auth);
        return archivo;
    }

    public org.springframework.core.io.Resource contenido(ArchivoRecurso archivo) { return media.recurso(archivo.getRutaArchivo()); }

    private Tipo detectar(byte[] bytes) {
        String start=new String(bytes,0,Math.min(bytes.length,16),StandardCharsets.ISO_8859_1);
        if(bytes.length>=8 && bytes[0]==(byte)0x89 && start.substring(1,8).equals("PNG\r\n\u001a\n")) return new Tipo("image/png","IMAGEN");
        if(bytes.length>=3 && bytes[0]==(byte)0xff && bytes[1]==(byte)0xd8 && bytes[2]==(byte)0xff) return new Tipo("image/jpeg","IMAGEN");
        if(bytes.length>=12 && start.substring(4,8).equals("ftyp") && soloAudioMp4(bytes)) return new Tipo("audio/mp4","AUDIO");
        if(start.startsWith("RIFF") && bytes.length>=12 && start.substring(8,12).equals("WAVE")) return new Tipo("audio/wav","AUDIO");
        if(start.startsWith("OggS")) return new Tipo("audio/ogg","AUDIO");
        if(start.startsWith("ID3") || (bytes.length>=2 && bytes[0]==(byte)0xff && (bytes[1]&0xe0)==0xe0)) return new Tipo("audio/mpeg","AUDIO");
        throw error(HttpStatus.BAD_REQUEST,"Usa una imagen JPG o PNG, o un audio MP3, M4A, WAV u OGG");
    }
    private record Tipo(String mime,String codigo) {}
    private boolean soloAudioMp4(byte[] bytes) {
        boolean[] tracks=new boolean[2];
        return explorarCajas(bytes,0,bytes.length,0,tracks) && tracks[0] && !tracks[1];
    }
    private boolean explorarCajas(byte[] bytes,int start,int end,int depth,boolean[] tracks) {
        if(depth>5) return false;
        int offset=start;
        while(offset<end) {
            if(end-offset<8) return false;
            long length=entero32(bytes,offset);
            int header=8;
            if(length==1) {
                if(end-offset<16 || entero32(bytes,offset+8)!=0) return false;
                length=entero32(bytes,offset+12);header=16;
            } else if(length==0) length=end-offset;
            if(length<header || length>end-offset) return false;
            String kind=new String(bytes,offset+4,4,StandardCharsets.US_ASCII);
            int next=offset+(int)length;
            if(kind.equals("moov") || kind.equals("trak") || kind.equals("mdia")) {
                if(!explorarCajas(bytes,offset+header,next,depth+1,tracks)) return false;
            } else if(kind.equals("hdlr") && length>=header+12) {
                String handler=new String(bytes,offset+header+8,4,StandardCharsets.US_ASCII);
                if(handler.equals("soun")) tracks[0]=true;
                if(handler.equals("vide")) tracks[1]=true;
            }
            offset=next;
        }
        return true;
    }
    private long entero32(byte[] b,int at) {
        return ((b[at]&0xffL)<<24)|((b[at+1]&0xffL)<<16)|((b[at+2]&0xffL)<<8)|(b[at+3]&0xffL);
    }
    private ResponseStatusException error(HttpStatus status,String message) { return new ResponseStatusException(status,message); }
}
