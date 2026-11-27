@echo off
setlocal
cd /d "%~dp0"

if not defined JAVA_HOME if exist "C:\Program Files\Java\jdk-21\bin\java.exe" set "JAVA_HOME=C:\Program Files\Java\jdk-21"
if defined JAVA_HOME set "PATH=%JAVA_HOME%\bin;%PATH%"

if not defined DB_HOST set "DB_HOST=127.0.0.1"
if not defined DB_PORT set "DB_PORT=3306"
if not defined DB_USERNAME set "DB_USERNAME=root"
if not defined DB_SCHEMA_PREFIX set "DB_SCHEMA_PREFIX=practika_xampp"
if not defined DB_DIALECT set "DB_DIALECT=org.hibernate.dialect.MariaDBDialect"
set "DB_URL="
set "RESET_DATABASE_ON_START=false"
set "SPRING_LIQUIBASE_DROP_FIRST=false"
set "IDENTITY_SERVICE_URL=http://127.0.0.1:8081"
set "ACADEMIC_SERVICE_URL=http://127.0.0.1:8082"
set "ACTIVITY_SERVICE_URL=http://127.0.0.1:8083"
set "GRADING_SERVICE_URL=http://127.0.0.1:8084"

call mvnw.cmd package -Dmaven.test.skip=true
if errorlevel 1 (
    echo Error al compilar el backend.
    pause
    exit /b 1
)

for %%S in (ms-auth ms-academic ms-content ms-grading api-gateway) do (
    start "%%S" /D "%~dp0%%S" cmd /k java -jar target\%%S-0.0.1-SNAPSHOT.jar --logging.level.org.springframework.web.servlet.DispatcherServlet=DEBUG
)

endlocal
