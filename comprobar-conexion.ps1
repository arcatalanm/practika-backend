[CmdletBinding()]
param(
    [string]$BaseUrl = 'http://127.0.0.1:8080',
    [string]$Usuario,
    [Security.SecureString]$Password
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$BaseUrl = $BaseUrl.TrimEnd('/')
foreach ($service in @('auth','academic','content','grading')) {
    $document = Invoke-RestMethod "$BaseUrl/openapi/$service" -TimeoutSec 10
    if (-not $document.openapi -or -not $document.paths) { throw "Respuesta OpenAPI invalida: $service" }
    Write-Host "OK: Gateway -> $service ($(@($document.paths.PSObject.Properties).Count) rutas)."
}
if ($Usuario) {
    if (-not $Password) { $Password = Read-Host 'Contrasena' -AsSecureString }
    $credential = New-Object System.Management.Automation.PSCredential($Usuario, $Password)
    $body = @{usuario=$Usuario; password=$credential.GetNetworkCredential().Password} | ConvertTo-Json
    try { $session = Invoke-RestMethod "$BaseUrl/api/v1/auth/login" -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 15 }
    finally { $body = $null; $credential = $null }
    if (-not $session.token) { throw 'Login sin token.' }
    $headers = @{Authorization="Bearer $($session.token)"}
    $profile = Invoke-RestMethod "$BaseUrl/api/v1/auth/me" -Headers $headers -TimeoutSec 15
    Write-Host "OK: login y perfil de $($profile.run), rol $($session.rol)."
    $paths = if ($session.rol -eq 'ADMIN') { @('auth/usuarios') } else { @('academic/secciones/asignaturas','content/unidades','grading/entregas/mias') }
    foreach ($path in $paths) {
        # Each request exercises the same Gateway URLs as the Android app.
        $result = Invoke-RestMethod "$BaseUrl/api/v1/$path" -Headers $headers -TimeoutSec 15
        Write-Host "OK: GET /api/v1/$path ($(@($result).Count) elementos)."
    }
} else {
    Write-Host 'Rutas verificadas. Para probar login y datos: .\comprobar-conexion.ps1 -Usuario correo_o_run'
}
