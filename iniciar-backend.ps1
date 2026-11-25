[CmdletBinding()]
param(
    [ValidateSet('ms-auth','ms-academic','ms-content','ms-grading','api-gateway')]
    [string]$Service,
    [ValidateRange(30,1800)][int]$StartupTimeoutSeconds = 300,
    [switch]$Offline
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$services = [ordered]@{'ms-auth'=8081; 'ms-academic'=8082; 'ms-content'=8083; 'ms-grading'=8084; 'api-gateway'=8080}

# Honor JAVA_HOME; also find the usual JDK 21 installations on Windows.
if (-not $env:JAVA_HOME) {
    $candidates = @("$env:ProgramFiles\Java\jdk-21", "$env:ProgramFiles\Android\Android Studio\jbr")
    foreach ($candidate in $candidates) {
        if (Test-Path "$candidate\bin\javac.exe") { $env:JAVA_HOME = $candidate; break }
    }
}
$java = if ($env:JAVA_HOME) { "$env:JAVA_HOME\bin\java.exe" } else { 'java.exe' }
$javaInfo = (& $java --version | Out-String)
if ($javaInfo -notmatch '^(?:java|openjdk) (\d+)' -or [int]$Matches[1] -lt 21) {
    throw 'Se requiere un JDK 21 o posterior. Configura JAVA_HOME.'
}
if (-not $env:DB_HOST) { $env:DB_HOST = '127.0.0.1' }
if (-not $env:DB_PORT) { $env:DB_PORT = '3306' }
if (-not $env:DB_USERNAME) { $env:DB_USERNAME = 'root' }
if (-not $env:DB_SCHEMA_PREFIX) { $env:DB_SCHEMA_PREFIX = 'practika_xampp' }
if ($env:DB_SCHEMA_PREFIX -notmatch '^[a-zA-Z0-9_]+$') { throw 'DB_SCHEMA_PREFIX solo admite letras, numeros y guion bajo.' }
if (-not $env:DB_DIALECT) { $env:DB_DIALECT = 'org.hibernate.dialect.MariaDBDialect' }
if ($Service -ne 'api-gateway') {
    if ($env:DB_HOST -notin @('127.0.0.1','localhost') -or $env:DB_SCHEMA_PREFIX -cne 'practika_xampp') {
        throw 'El reinicio automatico solo admite las bases locales practika_xampp_* en localhost o 127.0.0.1.'
    }
}
# Every native launch rebuilds the development schema using Liquibase, including
# its history tables, so all initialization changesets run again.
$env:RESET_DATABASE_ON_START = 'true'
$env:SPRING_LIQUIBASE_CONTEXTS = 'dev'
$env:IDENTITY_SERVICE_URL = 'http://127.0.0.1:8081'
$env:ACADEMIC_SERVICE_URL = 'http://127.0.0.1:8082'
$env:ACTIVITY_SERVICE_URL = 'http://127.0.0.1:8083'
$env:GRADING_SERVICE_URL = 'http://127.0.0.1:8084'
if (-not $env:GRADING_INTERNAL_TOKEN) { $env:GRADING_INTERNAL_TOKEN = [guid]::NewGuid().ToString('N') }

if ($Service) {
    # A distinct schema for each service; never inherit a Docker DB_URL.
    if ($Service -ne 'api-gateway') {
        $schema = $env:DB_SCHEMA_PREFIX + '_' + $Service.Substring(3)
        $env:DB_URL = "jdbc:mysql://$($env:DB_HOST):$($env:DB_PORT)/${schema}?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
    }
    Set-Location -LiteralPath (Join-Path $PSScriptRoot $Service)
    $mavenArgs = @('spring-boot:run', '-Dmaven.test.skip=true')
    if ($Offline) { $mavenArgs += '-o' }
    & '.\mvnw.cmd' @mavenArgs
    exit $LASTEXITCODE
}

$db = New-Object System.Net.Sockets.TcpClient
try {
    $connection = $db.ConnectAsync($env:DB_HOST, [int]$env:DB_PORT)
    if (-not $connection.Wait(3000)) { throw 'Tiempo de conexion agotado.' }
} catch { throw "MySQL no responde en $($env:DB_HOST):$($env:DB_PORT). Inicia MySQL desde XAMPP. $($_.Exception.Message)" }
finally { $db.Dispose() }
foreach ($port in $services.Values) {
    $probe = New-Object System.Net.Sockets.TcpClient
    try {
        if ($probe.ConnectAsync('127.0.0.1', $port).Wait(300)) {
            throw "El puerto $port ya esta ocupado. Deten la instancia anterior antes de iniciar."
        }
    } catch [System.AggregateException] { } finally { $probe.Dispose() }
}

$logDir = Join-Path $PSScriptRoot '.run'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$workers = @()
$launchTime = Get-Date
try {
    Write-Host 'Reinicio de datos: Liquibase eliminara las tablas de practika_xampp_auth, practika_xampp_academic, practika_xampp_content y practika_xampp_grading y cargara las migraciones dev.'
    foreach ($name in $services.Keys) {
        $workerArgs = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -Service {1}' -f $PSCommandPath, $name
        if ($Offline) { $workerArgs += ' -Offline' }
        $process = Start-Process powershell.exe -ArgumentList $workerArgs -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "$logDir\$name.log" -RedirectStandardError "$logDir\$name.err.log"
        $workers += [pscustomobject]@{Name=$name; Process=$process; Ready=$false}
        Write-Host "Iniciando $name en $($services[$name])..."
    }
    Write-Host "Logs: $logDir. Ctrl+C detiene los cinco servicios."
    $deadline = (Get-Date).AddSeconds($StartupTimeoutSeconds)
    while ($true) {
        foreach ($worker in $workers) {
            if ($worker.Process.HasExited) { throw "$($worker.Name) termino. Revisa $logDir\$($worker.Name).log y .err.log." }
            if (-not $worker.Ready) {
                try {
                    $response = Invoke-WebRequest "http://127.0.0.1:$($services[$worker.Name])/v3/api-docs" -UseBasicParsing -TimeoutSec 2
                    if ($response.StatusCode -eq 200) { $worker.Ready = $true; Write-Host "$($worker.Name): listo." }
                } catch { }
            }
        }
        if (@($workers | Where-Object { -not $_.Ready }).Count -eq 0) { break }
        if ((Get-Date) -gt $deadline) { throw "Se agoto el tiempo de inicio. Revisa los logs en $logDir." }
        Start-Sleep -Seconds 2
    }
    & (Join-Path $PSScriptRoot 'comprobar-conexion.ps1')
    Write-Host 'Backend listo: http://127.0.0.1:8080/swagger-ui.html'
    while ($true) {
        foreach ($worker in $workers) {
            if ($worker.Process.HasExited) { throw "$($worker.Name) termino. Revisa sus logs." }
        }
        Start-Sleep -Seconds 2
    }
} finally {
    # Stop the Spring JVMs first. This also lets Maven finish normally if Windows
    # does not allow taskkill to inspect an entire process tree.
    foreach ($worker in $workers) {
        $logFile = Join-Path $logDir "$($worker.Name).log"
        if (Test-Path -LiteralPath $logFile) {
            $startup = Select-String -LiteralPath $logFile -Pattern 'Starting \w+ using Java .+ with PID (\d+)' | Select-Object -Last 1
            if ($startup) {
                $applicationId = [int]$startup.Matches[0].Groups[1].Value
                $application = Get-Process -Id $applicationId -ErrorAction SilentlyContinue
                if ($application -and $application.ProcessName -eq 'java' -and $application.StartTime -ge $launchTime) {
                    Stop-Process -Id $applicationId -Force -ErrorAction Continue
                }
            }
        }
    }
    foreach ($worker in $workers) {
        if (-not $worker.Process.WaitForExit(3000)) {
            try {
                & taskkill.exe /PID $worker.Process.Id /T /F 2>&1 | Out-Null
            } catch { Write-Warning "No se pudo detener $($worker.Name), PID $($worker.Process.Id): $($_.Exception.Message)" }
        }
    }
}
