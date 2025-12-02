# Script para build de producción con variables de entorno
# Uso: .\build-production.ps1

Write-Host "🚀 Building Alumni UCC for Production..." -ForegroundColor Green
Write-Host ""

# ⚠️ IMPORTANTE: Cambiar API_BASE_URL a la URL de producción real
$API_BASE_URL = "https://aditya-pedimented-adela.ngrok-free.dev/api"  # TODO: Cambiar a URL de producción

Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "  Supabase: https://cqumdqgrcbrqlrmsfswg.supabase.co (mismo para dev y prod)"
Write-Host "  API URL: $API_BASE_URL"
Write-Host ""

# Verificar si es URL de producción
if ($API_BASE_URL -like "*ngrok*") {
    Write-Host "⚠️  WARNING: Usando URL de ngrok (desarrollo)" -ForegroundColor Yellow
    Write-Host "   Para producción, cambiar API_BASE_URL en este script" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "¿Continuar de todos modos? (s/n)"
    if ($continue -ne "s") {
        Write-Host "Build cancelado" -ForegroundColor Red
        exit 0
    }
}

# Limpiar build anterior
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Ejecutar tests
Write-Host ""
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
flutter test test/unit/utils/validators_test.dart test/widget/widgets/custom_button_test.dart

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed! Fix tests before building for production." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Tests passed!" -ForegroundColor Green

# Build APK (Supabase usa valores por defecto, solo override API URL si es diferente)
Write-Host ""
Write-Host "📦 Building APK..." -ForegroundColor Yellow

flutter build apk --release `
    --dart-define=API_BASE_URL=$API_BASE_URL

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 APK location:" -ForegroundColor Cyan
    Write-Host "  build\app\outputs\flutter-apk\app-release.apk"
    Write-Host ""
    Write-Host "📊 APK size:" -ForegroundColor Cyan
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $size = (Get-Item $apkPath).Length / 1MB
        Write-Host "  $([math]::Round($size, 2)) MB"
    }
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Test APK on physical device"
    Write-Host "  2. Upload to Firebase App Distribution"
    Write-Host "  3. Invite testers"
    Write-Host ""
    Write-Host "📝 Remember:" -ForegroundColor Cyan
    Write-Host "  - Supabase: Mismo para dev y prod ✅"
    Write-Host "  - API URL: Cambiar a producción cuando esté lista"
}
else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
