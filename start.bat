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
    start "" /b /D "%~dp0%%S" java -jar target\%%S-0.0.1-SNAPSHOT.jar --logging.level.org.springframework.web.servlet.DispatcherServlet=DEBUG
)

echo Los logs de los cinco servicios se muestran en esta ventana.
echo Puedes detenerlos con Ctrl+Pausa o cerrando esta ventana.
echo Esperando a que los servicios terminen de iniciar...
powershell.exe -NoProfile -Command "$deadline=(Get-Date).AddMinutes(3); $pending=@(8081,8082,8083,8084,8080); while ($pending.Count -gt 0 -and (Get-Date) -lt $deadline) { $pending=@($pending | Where-Object { try { $response=Invoke-WebRequest ('http://127.0.0.1:' + $_ + '/v3/api-docs') -UseBasicParsing -TimeoutSec 1; $response.StatusCode -ne 200 } catch { $true } }); if ($pending.Count -gt 0) { Start-Sleep -Seconds 2 } }; if ($pending.Count -gt 0) { Write-Host ('No terminaron de iniciar los servicios en los puertos: ' + ($pending -join ', ')); Write-Host 'Revisa los errores de los logs anteriores.'; exit 1 }; Write-Host 'Backend listo: http://127.0.0.1:8080/swagger-ui.html' -ForegroundColor Green"
if errorlevel 1 (
    pause
    exit /b 1
)
pause >nul

endlocal
