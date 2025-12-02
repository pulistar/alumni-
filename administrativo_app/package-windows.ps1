# Script para empaquetar la aplicación administrativa de Windows
# Ejecutar después de: flutter build windows --release

$AppName = "Alumni_Admin_UCC"
$Version = "1.0.0"
$BuildPath = "build\windows\x64\runner\Release"
$OutputPath = "dist"

Write-Host "📦 Empaquetando $AppName v$Version..." -ForegroundColor Cyan

# Crear carpeta de distribución
if (Test-Path $OutputPath) {
    Remove-Item -Path $OutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputPath | Out-Null

# Copiar archivos necesarios
Write-Host "📁 Copiando archivos..." -ForegroundColor Yellow
Copy-Item -Path "$BuildPath\*" -Destination $OutputPath -Recurse -Force

# Crear archivo README
$ReadmeContent = @"
# Alumni Admin UCC - Panel Administrativo

## Instalación

1. Extraer todos los archivos de este ZIP
2. Ejecutar `administrativo_app.exe`

## Requisitos

- Windows 10 o superior
- Conexión a internet

## Características

- Gestión de egresados
- Dashboard con estadísticas
- Reportes en Excel
- Gestión de documentos
- Autoevaluaciones

## Soporte

Para soporte técnico, contactar al administrador del sistema.

Versión: $Version
"@

Set-Content -Path "$OutputPath\README.txt" -Value $ReadmeContent

# Crear ZIP
$ZipName = "${AppName}_v${Version}_Windows.zip"
Write-Host "🗜️  Creando archivo ZIP..." -ForegroundColor Yellow

if (Test-Path $ZipName) {
    Remove-Item -Path $ZipName -Force
}

Compress-Archive -Path "$OutputPath\*" -DestinationPath $ZipName -CompressionLevel Optimal

Write-Host "✅ ¡Listo! Archivo creado: $ZipName" -ForegroundColor Green
Write-Host "📊 Tamaño: $((Get-Item $ZipName).Length / 1MB) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Ubicación: $(Get-Location)\$ZipName" -ForegroundColor White
