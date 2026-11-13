# Recursos de demostración

- `raton.svg` y `manzanas.svg`: ilustraciones SVG creadas para esta maqueta.
- `tierra.gif`: **Rotating earth (large)**, de **Marvel**, basado en imágenes de NASA. Copia sin modificaciones, bajo [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). [Archivo y autoría en Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Rotating_earth_(large).gif).
- `flores.mp4`: video de ejemplo de [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/video), descargado de [shared-assets/videos/flower.mp4](https://developer.mozilla.org/shared-assets/videos/flower.mp4), sin modificaciones.

Son recursos visuales de prueba. Los ejemplos anexados a «Representamos fracciones» permiten comprobar los cuatro formatos; no sustituyen sus preguntas ni alternativas por contenido curricular nuevo.

Con los datos de desarrollo, la cuenta `benjamin.pino@practika.local`, contraseña `PractikaDev2026!`, pertenece a la sección que tiene asignada la unidad «Fracciones en contexto». Ruta: **Mis cursos → Matemática → Fracciones en contexto → Actividades → Representamos fracciones**.

Los archivos pertenecen a `ms-content` y se sirven mediante `GET /api/v1/content/recursos/{nombre}` con autenticación. La migración `content-037` reemplaza las rutas antiguas `demo-assets/` por URLs relativas al gateway. Android ya no los empaqueta en sus assets. Se necesita reconstruir `ms-content`; el contexto Liquibase `dev` inserta los ejemplos en la base de datos.
