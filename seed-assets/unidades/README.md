# Miniaturas de unidad

Set de 16 miniaturas (4 por asignatura) que se cargan en **ms-content**, no en la app.
La app las lee desde `unidades.img_unidad` y las muestra en `UnitImage`.

## Archivos

| Asignatura | Archivos |
| --- | --- |
| Matemática | `mate_01_calculo.png`, `mate_02_geometria.png`, `mate_03_cuerpos_geometricos.png`, `mate_04_estadistica.png` |
| Lenguaje | `leng_01_lectura.png`, `leng_02_escritura.png`, `leng_03_literatura.png`, `leng_04_comunicacion.png` |
| Ciencias | `cien_01_microscopia.png`, `cien_02_quimica.png`, `cien_03_biologia.png`, `cien_04_fisica.png` |
| Historia | `hist_01_civilizaciones_antiguas.png`, `hist_02_roma_antigua.png`, `hist_03_exploraciones.png`, `hist_04_cartografia.png` |

- Formato: PNG, 320 × 240, entre 72 y 99 KB.
- Tamaño suficiente para la miniatura de 56 dp de la app. Si una unidad se muestra
  a ancho completo, conviene volver a exportar a 512 × 512 o más.
- No se empaquetan en el APK: viajan solo por el backend.

## Cómo subirlas

1. Inicia el stack y entra con una cuenta **UTP**.
2. Obtén el token:

   ```http
   POST /api/v1/auth/login
   ```

3. Completa la columna `idUnidad` en `mapeo.csv` con la unidad destino.
4. Ejecuta:

   ```powershell
   .\subir-miniaturas.ps1 -Token "<jwt>" -BaseUrl "http://localhost:8080"
   ```

El script usa `PUT /api/v1/content/unidades/{id}/imagen` con `multipart/form-data`,
igual que la pantalla de UTP. Solo procesa las filas que tengan `idUnidad`.
También puedes hacerlo desde Swagger (`http://localhost:8080/swagger-ui.html`).

## IDs y migraciones

El seed de desarrollo de Liquibase contiene 16 unidades, cuatro por asignatura.
`mapeo.csv` relaciona cada archivo con el ID estable de `ms-content`:

| Asignatura | IDs de unidad |
| --- | --- |
| Matemática | 910001, 910002, 910009, 910010 |
| Lenguaje | 910003, 910004, 910011, 910012 |
| Ciencias | 910007, 910008, 910013, 910014 |
| Historia | 910005, 910006, 910015, 910016 |

Las migraciones `academic-014-four-subject-image-objectives` y
`content-063-four-subject-image-units` sincronizan objetivos, títulos y
descripciones entre ambos servicios. Después de iniciar el stack de desarrollo,
el CSV queda listo para subir las 16 imágenes con el script anterior.
