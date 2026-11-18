param(
    [Parameter(Mandatory = $true)]
    [string]$Token,
    [string]$BaseUrl = "http://localhost:8080",
    [string]$Csv = (Join-Path $PSScriptRoot "mapeo.csv")
)

# Sube las miniaturas de unidad usando el endpoint real de ms-content.
# Requiere un JWT de una cuenta UTP y que la unidad exista.
# Edita mapeo.csv y completa idUnidad antes de ejecutar.

$rows = Import-Csv $Csv
$pending = @($rows | Where-Object { $_.idUnidad -match '^\d+$' })

if ($pending.Count -eq 0) {
    Write-Host "No hay filas con idUnidad en $Csv."
    Write-Host "Completa la columna idUnidad con el ID de la unidad destino y vuelve a ejecutar."
    exit 0
}

$ok = 0
$failed = 0
foreach ($row in $pending) {
    $file = Join-Path $PSScriptRoot $row.archivo
    if (-not (Test-Path $file)) {
        Write-Warning "Falta el archivo $($row.archivo)"
        $failed++
        continue
    }

    $uri = "$BaseUrl/api/v1/content/unidades/$($row.idUnidad)/imagen"
    $code = & curl.exe -sS -o NUL -w "%{http_code}" -X PUT $uri `
        -H "Authorization: Bearer $Token" `
        -F "imagen=@$file;type=image/png"

    if ($code -eq "200") {
        Write-Host "OK    $($row.archivo) -> unidad $($row.idUnidad)"
        $ok++
    } else {
        Write-Warning "ERROR $($row.archivo) -> unidad $($row.idUnidad): HTTP $code"
        $failed++
    }
}

Write-Host ""
Write-Host "Subidas: $ok. Fallidas: $failed."
if ($failed -gt 0) { exit 1 }
