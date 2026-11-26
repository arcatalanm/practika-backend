package com.practika.ms_content.storage;

import java.sql.*;
import liquibase.change.custom.CustomTaskChange;
import liquibase.database.Database;
import liquibase.database.jvm.JdbcConnection;
import liquibase.exception.CustomChangeException;
import liquibase.exception.SetupException;
import liquibase.exception.ValidationErrors;
import liquibase.resource.ResourceAccessor;

public class BlobToMediaMigration implements CustomTaskChange {
    private String directorio = "media";
    private String tabla;
    private String clave;
    private String carpeta;
    private String columnaMime;
    public void setDirectorio(String value) { directorio = value; }
    public void setTabla(String value) { tabla = value; }
    public void setClave(String value) { clave = value; }
    public void setCarpeta(String value) { carpeta = value; }
    public void setColumnaMime(String value) { columnaMime = value; }

    @Override public void execute(Database database) throws CustomChangeException {
        try {
            if (!tabla.matches("[a-z_]+") || !clave.matches("[a-z_]+") ||
                    (columnaMime != null && !columnaMime.matches("[a-z_]+"))) throw new IllegalArgumentException("Invalid migration metadata");
            // La ruta depende del entorno, no del checksum.
            String configured = System.getProperty("media.storage.path", System.getenv().getOrDefault("MEDIA_STORAGE_PATH", directorio));
            var media = new MediaStorage(configured);
            var connection = ((JdbcConnection) database.getConnection()).getUnderlyingConnection();
            String mime = columnaMime == null ? "'image/jpeg'" : columnaMime;
            try (var select = connection.createStatement();
                 var rows = select.executeQuery("SELECT " + clave + ", contenido, " + mime + " FROM " + tabla + " WHERE ruta_archivo IS NULL");
                 var update = connection.prepareStatement("UPDATE " + tabla + " SET ruta_archivo=? WHERE " + clave + "=?")) {
                while (rows.next()) {
                    String id = rows.getString(1);
                    if (!id.matches("[a-zA-Z0-9_-]+")) throw new IllegalArgumentException("Invalid legacy file identifier");
                    byte[] bytes = rows.getBytes(2);
                    if (bytes == null) throw new IllegalStateException("Missing legacy media for " + tabla + ":" + id);
                    String key = carpeta + "/legacy-" + id + MediaStorage.extension(rows.getString(3));
                    media.guardarMigrado(key, bytes);
                    update.setString(1, key); update.setString(2, id); update.executeUpdate();
                }
            }
        } catch (Exception ex) { throw new CustomChangeException("Could not export legacy media; binary data was not dropped", ex); }
    }
    @Override public String getConfirmationMessage() { return "Legacy media exported to service media directory: " + tabla; }
    @Override public void setUp() throws SetupException { }
    @Override public void setFileOpener(ResourceAccessor accessor) { }
    @Override public ValidationErrors validate(Database database) { return new ValidationErrors(); }
}
