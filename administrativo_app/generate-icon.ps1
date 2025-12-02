# Script para generar icono de Windows (.ico) desde PNG
# Requiere ImageMagick instalado

param(
    [string]$InputPng = "flutter_01.png",
    [string]$OutputIco = "windows\runner\resources\app_icon.ico"
)

Write-Host "🎨 Generando icono de Windows..." -ForegroundColor Cyan

# Verificar si existe ImageMagick
$magickPath = Get-Command magick -ErrorAction SilentlyContinue

if (-not $magickPath) {
    Write-Host "⚠️  ImageMagick no está instalado." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor White
    Write-Host "1. Instalar ImageMagick desde: https://imagemagick.org/script/download.php#windows" -ForegroundColor Gray
    Write-Host "2. O usar un convertidor online:" -ForegroundColor Gray
    Write-Host "   - https://convertio.co/es/png-ico/" -ForegroundColor Gray
    Write-Host "   - https://www.icoconverter.com/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Después de convertir, guarda el archivo como:" -ForegroundColor White
    Write-Host "  $OutputIco" -ForegroundColor Cyan
    exit 1
}

# Verificar que existe el PNG
if (-not (Test-Path $InputPng)) {
    Write-Host "❌ No se encontró el archivo: $InputPng" -ForegroundColor Red
    exit 1
}

# Crear directorio si no existe
$outputDir = Split-Path $OutputIco -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Generar ICO con múltiples tamaños
Write-Host "📐 Generando icono con múltiples tamaños..." -ForegroundColor Yellow
& magick convert $InputPng `
    -define icon:auto-resize=256, 128, 96, 64, 48, 32, 16 `
    $OutputIco

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Icono generado exitosamente: $OutputIco" -ForegroundColor Green
    Write-Host "📊 Tamaño: $((Get-Item $OutputIco).Length / 1KB) KB" -ForegroundColor Cyan
}
else {
    Write-Host "❌ Error al generar el icono" -ForegroundColor Red
    exit 1
}
