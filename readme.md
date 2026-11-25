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
- **Cada arranque con `iniciar-backend.bat` o `iniciar-backend.ps1` reinicia los datos de las cuatro bases locales.** El lanzador activa `RESET_DATABASE_ON_START=true` (`spring.liquibase.drop-first`) y el contexto `dev`: Liquibase elimina las tablas, incluido su historial, y vuelve a ejecutar las migraciones desde cero. Se recuperan las 20 cuentas y el contenido inicial; se pierden las modificaciones, usuarios, entregas y publicaciones creados durante las pruebas. No es necesario importar SQL en phpMyAdmin. Usuario de base predeterminado: `root`, sin contraseña; configurable con `DB_USERNAME` y `DB_PASSWORD`.
- El lanzador comparte las URLs locales y una clave interna temporal entre content y grading. No necesita Apache ni contenedores. Conservamos los archivos de Docker; Compose declara el dialecto MySQL para sus bases MySQL 8.4.
- El reinicio automático está limitado por el lanzador al host local y al prefijo exacto `practika_xampp`. Los nombres anteriores `practika_*`, con referencias InnoDB dañadas, quedan fuera de este reinicio. Docker conserva sus nombres mediante `DB_URL` y no activa `RESET_DATABASE_ON_START`.
- Compila desde la raíz (`.\mvnw.cmd clean package`). Se construyen los cinco servicios, las pruebas de persistencia requieren MySQL para compilar y empaquetar sin pruebas usa `-DskipTests`.
- Para trabajar en un servicio por separado, arranca su MySQL y ejecuta el wrapper del servicio con `spring-boot:run`. Las peticiones autenticadas de academic, content y grading también necesitan `ms-auth`.
- `build-jars.bat` construye todos los jars desde la raíz omitiendo la ejecución de pruebas con `limpiar.bat` limpia los módulos target. Los Dockerfile consumen `target/<servicio>-0.0.1-SNAPSHOT.jar`.

### Conectar Android y comprobar peticiones

1. Espera a que el lanzador muestre `Backend listo`. Swagger: `http://127.0.0.1:8080/swagger-ui.html`.
2. Desde `../practika-ui`, ejecuta `.\Conectar-USB.bat` con el celular autorizado para depuración USB o el emulador encendido. El script verifica el Gateway y ejecuta `adb reverse tcp:8080 tcp:8080`.
3. Compila e instala la variante **debug** de Android. `PRACTIKA_API_URL` en `gradle.properties` apunta a `http://127.0.0.1:8080/`; Retrofit envía desde allí las peticiones a los cuatro servicios a través del Gateway. El reenvío USB permite usar esa misma URL desde Android. Repite el reenvío al reconectar el dispositivo.
4. Para comprobar las rutas desde el computador: `.\comprobar-conexion.ps1`. Para comprobar además login, perfil, cursos, unidades y entregas: `.\comprobar-conexion.ps1 -Usuario ana.lagos@practika.local`. Solicita la contraseña sin mostrarla y no imprime el token.

Si no usas USB ni reenvío, el emulador estándar de Android alcanza el computador en `http://10.0.2.2:8080/`; un celular por Wi-Fi necesita la IP LAN del computador. Configura `-PPRACTIKA_API_URL=http://IP:8080/` al compilar debug. Una URL modificada requiere recompilar la app. La variante release usa su configuración HTTPS independiente.

Para iniciar y reiniciar los datos de un solo servicio, ejecuta `.\iniciar-backend.ps1 -Service ms-auth` (o el nombre correspondiente). Para ejecutar Maven directamente, entra en su carpeta y ejecuta `./mvnw spring-boot:run` (Windows: `.\mvnw.cmd spring-boot:run`); en ese caso solo se reinician datos si defines `RESET_DATABASE_ON_START=true` en la terminal. Usa el mismo `GRADING_INTERNAL_TOKEN` en content y grading si los inicias manualmente. Cada `application.properties` permite cambiar el dialecto mediante `DB_DIALECT` y la URL completa mediante `DB_URL`.

Comprobación local realizada: arranque y reinicio de los cinco servicios sobre XAMPP, migraciones completas, 20 usuarios (1 ADMIN, 1 UTP, 3 profesores y 15 estudiantes), login por correo y RUN, perfil, cursos, unidades y entregas con HTTP 200 a través del Gateway. Se usó una cuenta temporal, eliminada al terminar. UTP ve las 16 unidades del catálogo; el estudiante recibe una lista vacía mientras no existan evaluaciones publicadas. También se comprobó que el lanzador detiene los demás servicios cuando falla uno. ADB devolvió acceso denegado al directorio de configuración, por lo que falta verificar el flujo desde un dispositivo Android.

El Hibernate actual emite un aviso porque su dialecto estándar declara MariaDB 10.6 como versión mínima y XAMPP incluye 10.4. Las comprobaciones anteriores pasaron con esta instalación; no se han verificado todos los flujos de escritura.

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
