[CmdletBinding()]
param(
    [string]$BaseUrl = 'http://127.0.0.1:8080',
    [string]$Usuario,
    [Security.SecureString]$Password,
    [switch]$ComprobarPersistencia
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$BaseUrl = $BaseUrl.TrimEnd('/')
if ($ComprobarPersistencia -and -not $Usuario) { throw 'Indica -Usuario con una cuenta UTP para comprobar escrituras.' }
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
        $result = Invoke-RestMethod "$BaseUrl/api/v1/$path" -Headers $headers -TimeoutSec 15
        Write-Host "OK: GET /api/v1/$path ($(@($result).Count) elementos)."
    }
    if ($ComprobarPersistencia) {
        if ($session.rol -ne 'UTP') { throw 'La prueba de escritura requiere una cuenta UTP.' }
        $objectives = Invoke-RestMethod "$BaseUrl/api/v1/academic/objetivos" -Headers $headers -TimeoutSec 15
        $objective = $objectives | Where-Object { $_.asignatura.activo } | Select-Object -First 1
        if (-not $objective) { throw 'Se necesita un objetivo de una asignatura activa para probar unidades.' }
        $unit = $null
        try {
            $data = @{idAsignatura=$objective.asignatura.id; idObjetivo=$objective.id; titulo="Prueba persistencia $([guid]::NewGuid().ToString('N'))"; descripcion='Unidad temporal de comprobacion HTTP'}
            $unit = Invoke-RestMethod "$BaseUrl/api/v1/content/unidades" -Method Post -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ($data | ConvertTo-Json) -TimeoutSec 15
            $path = "$BaseUrl/api/v1/content/unidades/$($unit.id)"
            $saved = Invoke-RestMethod $path -Headers $headers -TimeoutSec 15
            if ($saved.unidad.titulo -ne $data.titulo) { throw 'La unidad creada no se recupero por su ID.' }
            $data.titulo += ' editada'
            Invoke-RestMethod $path -Method Put -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ($data | ConvertTo-Json) -TimeoutSec 15 | Out-Null
            $saved = Invoke-RestMethod $path -Headers $headers -TimeoutSec 15
            $catalog = Invoke-RestMethod "$BaseUrl/api/v1/content/unidades?idAsignatura=$($data.idAsignatura)" -Headers $headers -TimeoutSec 15
            if ($saved.unidad.titulo -ne $data.titulo -or -not ($catalog | Where-Object { $_.unidad.id -eq $unit.id })) {
                throw 'La edicion no se recupero en el detalle o la unidad no aparece en el catalogo.'
            }
            Write-Host 'OK: crear, consultar, editar y volver a consultar una unidad por HTTP.'
        } finally {
            if ($unit) {
                Invoke-RestMethod "$BaseUrl/api/v1/content/unidades/$($unit.id)" -Method Delete -Headers $headers -TimeoutSec 15 | Out-Null
                Write-Host 'OK: unidad temporal eliminada.'
            }
        }
    }
} else {
    Write-Host 'Rutas verificadas. Para probar login y datos: .\comprobar-conexion.ps1 -Usuario correo_o_run'
}
