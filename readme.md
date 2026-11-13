# PRACTIKA — Backend

Backend PRACTIKA Spring Boot + API Gateway. Cada servicio tiene su propia base de datos (Database per Service) y los IDs compartidos son referencias lógicas (sin FK entre bases).

## Servicios

| Servicio | Puerto | Base de datos | Responsabilidad |
|---|---:|---|---|
| `api-gateway` | 8080 | — | Punto de entrada único para las solicitudes de los clientes |
| `ms-auth` | 8081 | `practika_auth` | Usuarios, secciones, matrículas, login/JWT |
| `ms-academic` | 8082 | `practika_academic` | Asignaturas, OA
| `ms-content` | 8083 | `practika_content` | Unidades, catálogo, publicaciones versionadas, archivos |
| `ms-grading` | 8084 | `practika_grading` | Entregas, respuestas y revisión |

## Requisitos y ejecución

- Java 21, MySQL 8.4.
- Liquibase crea/migra tablas al arrancar. Credenciales por defecto: `root` sin contraseña (configurables con `DB_USERNAME` / `DB_PASSWORD`).
- Compila desde la raíz (`.\mvnw.cmd clean package`). Se construyen los cinco servicios, las pruebas de persistencia requieren MySQL para compilar y empaquetar sin pruebas usa `-DskipTests`.
- Para trabajar en un servicio por separado, arranca su MySQL y ejecuta el wrapper del servicio con `spring-boot:run`. Las peticiones autenticadas de academic, content y grading también necesitan `ms-auth`.
- `build-jars.bat` construye todos los jars desde la raíz omitiendo la ejecución de pruebas con `limpiar.bat` limpia los módulos target. Los Dockerfile consumen `target/<servicio>-0.0.1-SNAPSHOT.jar`.

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

## Tablas por base

- `practika_auth`: `niveles_educativos`, `roles`, `secciones`, `usuarios`, `fotos_perfil`, `matriculas`
- `practika_academic`: `asignaturas`, `objetivo_aprendizajes`
- `practika_content`: `periodos_academicos`, `cursos_portal`, `docentes_cursos_portal`, `unidades`, `unidades_cursos`, `actividades`, `pruebas`, `tipos_pregunta`, `preguntas`, `opciones`, `tipos_material`, `materiales`, `archivos_recursos`, `evaluaciones_asignadas`, `archivos_evaluacion`, `materiales_unidad_archivados`
- `practika_grading`: `entregas`, `estados_revision`, `respuestas`, `respuestas_opciones`, `observacion_pedagogicas`
