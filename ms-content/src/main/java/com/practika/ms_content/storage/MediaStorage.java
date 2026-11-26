package com.practika.ms_content.storage;

import java.io.IOException;
import java.nio.file.*;
import java.util.Arrays;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.server.ResponseStatusException;

@Component
public class MediaStorage {
    private final Path root;

    public MediaStorage(@Value("${media.storage.path:media}") String configured) {
        Path base = Path.of(configured);
        if (configured.equals("media") && Files.isDirectory(Path.of("ms-content"))) base = Path.of("ms-content", "media");
        root = base.toAbsolutePath().normalize();
        try { Files.createDirectories(root); }
        catch (IOException ex) { throw unavailable(ex); }
    }

    public String guardar(byte[] bytes, String folder, String mime) {
        String key = folder + "/" + UUID.randomUUID() + extension(mime);
        guardarMigrado(key, bytes);
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override public void afterCompletion(int status) {
                    if (status != STATUS_COMMITTED) eliminar(key);
                }
            });
        }
        return key;
    }

    public void guardarMigrado(String key, byte[] bytes) {
        Path target = resolve(key);
        Path temporary = null;
        try {
            Files.createDirectories(target.getParent());
            // Evita rutas fuera de media.
            if (!target.getParent().toRealPath().startsWith(root.toRealPath())) throw new IllegalArgumentException("Invalid media path");
            if (Files.exists(target)) {
                if (!Arrays.equals(leer(key), bytes)) throw new IOException("Existing media differs: " + key);
                return;
            }
            temporary = Files.createTempFile(target.getParent(), ".upload-", ".tmp");
            Files.write(temporary, bytes);
            Files.move(temporary, target);
            if (!Arrays.equals(leer(key), bytes)) throw new IOException("Media verification failed: " + key);
        } catch (IOException ex) { throw unavailable(ex); }
        finally { if (temporary != null) try { Files.deleteIfExists(temporary); } catch (IOException ignored) { } }
    }

    public byte[] leer(String key) {
        try { return Files.readAllBytes(checkedFile(key)); }
        catch (IOException ex) { throw unavailable(ex); }
    }

    public Resource recurso(String key) {
        try { return new FileSystemResource(checkedFile(key)); }
        catch (IOException ex) { throw unavailable(ex); }
    }

    private Path checkedFile(String key) throws IOException {
        Path file = resolve(key).toRealPath();
        if (!file.startsWith(root.toRealPath()) || !Files.isRegularFile(file)) throw new IOException("Invalid media file");
        return file;
    }

    private Path resolve(String key) {
        if (key == null || key.isBlank() || key.contains("\\") || Path.of(key).isAbsolute()) throw new IllegalArgumentException("Invalid media key");
        Path file = root.resolve(key).normalize();
        if (!file.startsWith(root) || file.equals(root)) throw new IllegalArgumentException("Invalid media key");
        return file;
    }

    private void eliminar(String key) {
        try { Files.deleteIfExists(resolve(key)); }
        catch (IOException ex) { throw unavailable(ex); }
    }

    public static String extension(String mime) {
        return switch (mime) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "audio/mpeg" -> ".mp3";
            case "audio/mp4", "audio/x-m4a" -> ".m4a";
            case "audio/wav", "audio/x-wav" -> ".wav";
            case "audio/ogg" -> ".ogg";
            case "application/pdf" -> ".pdf";
            default -> ".bin";
        };
    }

    private static ResponseStatusException unavailable(IOException ex) {
        return new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "No se pudo acceder al archivo multimedia en el servidor", ex);
    }
}
