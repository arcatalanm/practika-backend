# PRACTIKA — Backend

Backend PRACTIKA Spring Boot + API Gateway. Cada servicio tiene su propia base de datos (Database per Service) y los IDs compartidos son referencias lógicas (sin FK entre bases).

## Servicios

| Servicio | Puerto | Base de datos | Responsabilidad |
|---|---:|---|---|
| `api-gateway` | 8080 | — | Punto de entrada único para las solicitudes de los clientes |
| `ms-auth` | 8081 | `practika_xampp_auth` | Usuarios, secciones, matrículas, login/JWT |
| `ms-academic` | 8082 | `practika_xampp_academic` | Asignaturas, OA
| `ms-content` | 8083 | `practika_xampp_content` | Unidades, catálogo, publicaciones versionadas, archivos |
| `ms-grading` | 8084 | `practika_xampp_grading` | Entregas, respuestas y revisión |

## Requisitos y ejecución

- JDK 21 y MySQL de XAMPP iniciado desde su panel. La instalación local usa MariaDB 10.4 en `127.0.0.1:3306`; el dialecto predeterminado es `org.hibernate.dialect.MariaDBDialect`.
- Desde esta carpeta, ejecuta `./iniciar-backend.bat` (PowerShell: `.\iniciar-backend.ps1`). Arranca los cuatro microservicios y el Gateway en paralelo mediante `mvnw.cmd spring-boot:run`, comprueba sus rutas y mantiene la consola abierta. **Ctrl+C detiene los cinco procesos.** Los logs quedan en `.run/<servicio>.log` y `.run/<servicio>.err.log`. Si un proceso falla o un puerto está ocupado, el script lo informa y detiene los procesos que inició.
- **Los datos se conservan entre arranques.** El lanzador fuerza `RESET_DATABASE_ON_START=false` y `SPRING_LIQUIBASE_DROP_FIRST=false`, incluso si la terminal hereda valores antiguos. Liquibase conserva su historial y aplica solamente migraciones pendientes; el contexto `dev` carga los datos iniciales una sola vez. No es necesario importar SQL en phpMyAdmin. Usuario de base predeterminado: `root`, sin contraseña; configurable con `DB_USERNAME` y `DB_PASSWORD`.
- El lanzador comparte las URLs locales y una clave interna temporal entre content y grading. No necesita Apache ni contenedores. Conservamos los archivos de Docker; Compose declara el dialecto MySQL para sus bases MySQL 8.4.
- Cada servicio consulta su propia base. En XAMPP los nombres son `practika_xampp_*`; Docker usa `practika_*` en sus volúmenes persistentes. Comprueba el host, puerto y esquema del proceso antes de comparar datos en phpMyAdmin. El lanzador local no utiliza las bases anteriores `practika_*` de XAMPP.
- Compila desde la raíz (`.\mvnw.cmd clean package`). Se construyen los cinco servicios y se ejecutan las pruebas unitarias. Para compilar y empaquetar sin ejecutarlas usa `-DskipTests`.
- Para trabajar en un servicio por separado, arranca su MySQL y ejecuta el wrapper del servicio con `spring-boot:run`. Las peticiones autenticadas de academic, content y grading también necesitan `ms-auth`.
- `build-jars.bat` construye todos los jars desde la raíz omitiendo la ejecución de pruebas con `limpiar.bat` limpia los módulos target. Los Dockerfile consumen `target/<servicio>-0.0.1-SNAPSHOT.jar`.

### Pruebas unitarias con Mockito

Ejecuta `.\mvnw.cmd test` desde la raíz. Hay cinco pruebas con JUnit 5 y Mockito; no requieren MySQL ni servicios externos.

### Conectar Android y comprobar peticiones

1. Espera a que el lanzador muestre `Backend listo`. Swagger: `http://127.0.0.1:8080/swagger-ui.html`.
2. Desde `../practika-ui`, ejecuta `.\Conectar-USB.bat` con el celular autorizado para depuración USB o el emulador encendido. El script verifica el Gateway y ejecuta `adb reverse tcp:8080 tcp:8080`.
3. Compila e instala la variante **debug** de Android. `PRACTIKA_API_URL` en `gradle.properties` apunta a `http://127.0.0.1:8080/`; Retrofit envía desde allí las peticiones a los cuatro servicios a través del Gateway. El reenvío USB permite usar esa misma URL desde Android. Repite el reenvío al reconectar el dispositivo.
4. Para comprobar las rutas desde el computador: `.\comprobar-conexion.ps1`. Para comprobar además login, perfil, cursos, unidades y entregas: `.\comprobar-conexion.ps1 -Usuario ana.lagos@practika.local`. Solicita la contraseña sin mostrarla y no imprime el token.

Si no usas USB ni reenvío, el emulador estándar de Android alcanza el computador en `http://10.0.2.2:8080/`; un celular por Wi-Fi necesita la IP LAN del computador. Configura `-PPRACTIKA_API_URL=http://IP:8080/` al compilar debug. Una URL modificada requiere recompilar la app. La variante release usa su configuración HTTPS independiente.

Para iniciar un solo servicio conservando sus datos, ejecuta `.\iniciar-backend.ps1 -Service ms-auth` (o el nombre correspondiente). También puedes ejecutar Maven desde su carpeta (`.\mvnw.cmd spring-boot:run`); deja `RESET_DATABASE_ON_START=false` y `SPRING_LIQUIBASE_DROP_FIRST=false`. Usa el mismo `GRADING_INTERNAL_TOKEN` en content y grading si los inicias manualmente. Cada `application.properties` permite cambiar el dialecto mediante `DB_DIALECT` y la URL completa mediante `DB_URL`.

Comprobación local realizada: arranque y reinicio de los cinco servicios sobre XAMPP, migraciones completas, 20 usuarios (1 ADMIN, 1 UTP, 3 profesores y 15 estudiantes), login por correo y RUN, perfil, cursos, unidades y entregas con HTTP 200 a través del Gateway. Se usó una cuenta temporal, eliminada al terminar. UTP ve las 16 unidades del catálogo; el estudiante recibe una lista vacía mientras no existan evaluaciones publicadas. También se comprobó que el lanzador detiene los demás servicios cuando falla uno. ADB devolvió acceso denegado al directorio de configuración, por lo que falta verificar el flujo desde un dispositivo Android.

El Hibernate actual emite un aviso porque su dialecto estándar declara MariaDB 10.6 como versión mínima y XAMPP incluye 10.4. Las comprobaciones anteriores pasaron con esta instalación; no se han verificado todos los flujos de escritura.

### Verificar persistencia de unidades

UTP crea y edita el catálogo con `POST /api/v1/content/unidades` y `PUT /api/v1/content/unidades/{id}`. Comprueba el resultado con `GET /api/v1/content/unidades/{id}` y `GET /api/v1/content/unidades?idAsignatura=...`, usando la misma sesión UTP que Android. La fila se almacena en `practika_xampp_content.unidades` al usar el lanzador local. Tras detener y volver a iniciar el backend, el mismo ID debe conservar el título y la descripción editados.

El catálogo UTP incluye unidades sin evaluaciones. El estudiante consulta únicamente contenido seleccionado por su profesor para su sección; su lista puede estar vacía aunque la unidad exista en la base. Para que aparezca, UTP prepara una actividad o prueba con preguntas y el profesor la selecciona mediante `POST /api/v1/content/secciones/asignaturas/{idCurso}/evaluaciones/{idEvaluacion}/seleccionar`.

Las rutas antiguas `POST /content/cursos/{idCurso}/unidades`, `POST /content/asignaciones` y `POST /content/cursos/{idCurso}/evaluaciones/publicar` responden 410 y están marcadas como obsoletas en Swagger. Usa las rutas de catálogo y selección anteriores (con el prefijo `/api/v1`).

Prueba de escritura desde PowerShell: `.\comprobar-conexion.ps1 -Usuario utp@practika.local -ComprobarPersistencia`. Solicita la contraseña, crea una unidad temporal, verifica su creación y edición con nuevas peticiones GET y la elimina al terminar. Esta comprobación no reinicia los servicios; para verificar durabilidad entre arranques, conserva una unidad propia y consulta su mismo ID después de reiniciar.

### Tiempo en el inicio

`GET /api/v1/content/tiempo` consulta Open-Meteo para Antonio Varas 666, Providencia. Devuelve temperatura actual, mínima, máxima y estado del cielo. La respuesta se comparte en memoria durante diez minutos y Android muestra la tarjeta al final del inicio.

Configuración opcional: `WEATHER_API_URL`, `WEATHER_LOCATION_NAME`, `WEATHER_LATITUDE` y `WEATHER_LONGITUDE`. No necesita clave ni tablas nuevas.

### Secciones de primero y segundo básico

Se admiten primero y segundo básico. Los demás niveles quedan inactivos y conservan su historial. Los cursos de las asignaturas se crean a partir de las secciones activas de `ms-auth`.

### Archivos multimedia

Los archivos se guardan en `ms-auth/media` (fotos de perfil) y `ms-content/media` (imágenes y audios). La base de datos conserva rutas y metadatos. Liquibase exporta los BLOB anteriores antes de quitar las columnas binarias.

`MEDIA_STORAGE_PATH` permite cambiar la carpeta. Docker monta ambas carpetas para conservar los archivos. Se excluyen de Git; respalda las bases de datos y las carpetas `media` juntas.

### Usuario administrador

En base vacía, define `ADMIN_INICIAL_RUN`, `ADMIN_INICIAL_NOMBRE1`, `ADMIN_INICIAL_APPATERNO`, `ADMIN_INICIAL_APMATERNO`, `ADMIN_INICIAL_EMAIL`, `ADMIN_INICIAL_PASSWORD` (mín. 12 caracteres). El RUN se valida con dígito verificador y se guarda con BCrypt. Elimina esas variables tras crear la cuenta.

### Roles y flujo

1. **ADMIN** crea usuarios y asigna roles.
2. **UTP** administra secciones, asignaturas, objetivos, períodos y cursos del portal.
3. **PROFESOR** asigna unidades de estudio y revisa respuestas de actividades.
4. **ESTUDIANTE** ve unidades asignadas a su curso, mira materiales y realiza actividades.

Rutas:
- `/api/v1/auth` — identidad
- `/api/v1/academic` — asignaturas/objetivos
- `/api/v1/content` — catálogo y publicaciones
- `/api/v1/grading` — entregas y revisión

Solo login es público, mientras que `POST /api/v1/auth/register` requiere token ADMIN.

## JWT

- Login → `token`, `tipo: "Bearer"`, `expiraEn` (86400 s por defecto).
- Envía `Authorization: Bearer <token>` en rutas protegidas.
- Solo `ms-auth` emite y valida JWT (firma, expiración, emisor y claims) y comprueba la cuenta activa y su rol vigente en la base. El gateway enruta.
- `GET /api/v1/auth/identity`, autenticado con el Bearer original, devuelve únicamente `{ "run": 12345678, "rol": "PROFESOR" }`. Academic, content y grading consultan esa identidad en cada petición con Bearer, sin decodificar el token ni confiar en cabeceras de identidad del cliente. Conservan la autorización de sus recursos mediante Spring Security.
- `JWT_SECRET` y `JWT_ISSUER` se configuran únicamente en `ms-auth`. Los otros servicios usan `IDENTITY_SERVICE_URL` (por defecto `http://localhost:8081`). No hay caché de identidades: la desactivación y los cambios de rol se aplican en la siguiente consulta a auth.
- Los errores conservan `timestamp`, `status`, `error`, `message`, `path`: token rechazado devuelve 401, falta de permisos 403, auth no disponible o respuesta inválida 503. El 503 permite reintentar sin tratar la sesión como vencida. Los tiempos de conexión y lectura son 2 y 3 segundos, configurables con `services.identity.connect-timeout-ms` y `services.identity.read-timeout-ms`.
- OpenFeign reenvía el token automáticamente en llamadas internas de `ms-content` y `ms-grading`.
- Sin refresh token: al vencer, la app debe volver a autenticarse.

## Swagger / OpenAPI

| Interfaz | URL |
|---|---|
| Gateway | http://localhost:8080/swagger-ui.html |
| Auth | http://localhost:8081/swagger-ui.html |
| Académico | http://localhost:8082/swagger-ui.html |
| Contenido | http://localhost:8083/swagger-ui.html |
| Calificaciones | http://localhost:8084/swagger-ui.html |

Desactiva en producción con `OPENAPI_ENABLED=false`.
