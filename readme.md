## PRACTIKA – Backend

Backend de PRACTIKA, una plataforma educativa construida con una arquitectura de microservicios sobre Spring Boot, con un API Gateway como único punto de entrada y centralizador de peticiones.

Se aplica el principio Database per Service: cada microservicio cuenta con su propia base de datos, y las relaciones entre servicios se resuelven mediante IDs de referencia lógica y llamadas HTTP con OpenFeign.

## Estructura del Proyecto

```bash
practika-backend/
├── api-gateway/
├── identity-service/
├── academic-service/
├── activity-service/
└── grading-service/

```
## Ejecución

Los servicios pueden levantarse en cualquier orden, ya que no se utiliza service discovery. Desde la carpeta de cada proyecto, ejecutar:

```bash
./mvnw spring-boot:run
```