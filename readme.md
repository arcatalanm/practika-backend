# PRACTIKA — Backend

Backend PRACTIKA Spring Boot + API Gateway. Cada servicio tiene su propia base de datos (Database per Service) y los IDs compartidos son referencias lógicas (sin FK entre bases).

## Servicios

| Servicio | Puerto | Base de datos | Responsabilidad |
|---|---:|---|---|
| `api-gateway` | 8080 | — | Punto de entrada único para las solicitudes de los clientes |
| `ms-auth` | 8081 | `practika_xampp_auth` | Usuarios, secciones, matrículas, login/JWT |
| `ms-academic` | 8082 | `practika_xampp_academic` | Asignaturas, OA |
| `ms-content` | 8083 | `practika_xampp_content` | Unidades, catálogo, publicaciones versionadas, archivos |
| `ms-grading` | 8084 | `practika_xampp_grading` | Entregas, respuestas y revisión |

## Requisitos y ejecución

Requiere JDK 21 y MySQL o MariaDB. Cada servicio utiliza una base independiente y aplica sus migraciones pendientes con Liquibase.

Para compilar y ejecutar las pruebas desde la raíz:

```sh
./mvnw clean package
```

En Windows, usa `mvnw.cmd` en lugar de `./mvnw`.

### Desarrollo local

Inicia MySQL y ejecuta `./mvnw spring-boot:run` desde la carpeta de cada servicio, en terminales separadas. Inicia primero `ms-auth`, luego `ms-academic`, `ms-content`, `ms-grading` y `api-gateway`.

La configuración predeterminada utiliza MariaDB en `127.0.0.1:3306`, usuario `root` y las bases `practika_xampp_*`. Configura `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD` y `DB_SCHEMA_PREFIX` según tu instalación. `DB_URL` permite indicar la URL JDBC completa y `DB_DIALECT` cambia el dialecto de Hibernate.

### Catálogo y publicaciones

UTP crea y edita unidades mediante `POST /api/v1/content/unidades` y `PUT /api/v1/content/unidades/{id}`. El profesor selecciona las evaluaciones de su sección mediante `POST /api/v1/content/secciones/asignaturas/{idCurso}/evaluaciones/{idEvaluacion}/seleccionar`. Los estudiantes consultan las evaluaciones publicadas para su sección.

### Tiempo en el inicio (API Externa)

`GET /api/v1/content/tiempo` consulta Open-Meteo para Antonio Varas 666, Providencia. Devuelve temperatura actual, mínima, máxima y estado del cielo. La respuesta se comparte en memoria durante diez minutos y Android muestra la tarjeta al final del inicio.


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
