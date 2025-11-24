# =====================================================
# Script de Prueba - Módulo de Autoevaluación
# =====================================================
# Este script te ayuda a probar los endpoints de autoevaluación
# =====================================================

# IMPORTANTE: Reemplaza {TOKEN} con tu token de Supabase Auth
$token = "TU_TOKEN_AQUI"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# =====================================================
# 1. OBTENER PREGUNTAS
# =====================================================
Write-Host "`n1. Obteniendo preguntas..." -ForegroundColor Yellow
try {
    $preguntas = Invoke-RestMethod -Uri "http://localhost:3000/api/autoevaluacion/preguntas" `
        -Method Get `
        -Headers $headers
    
    Write-Host "✅ Preguntas obtenidas: $($preguntas.Count)" -ForegroundColor Green
    if ($preguntas.Count > 0) {
        $primeraPregunta = $preguntas[0]
        Write-Host "ID Primera Pregunta: $($primeraPregunta.id)"
        Write-Host "Texto: $($primeraPregunta.texto)"
    }
}
catch {
    Write-Host "❌ Error al obtener preguntas: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Nota: Asegúrate de haber subido los documentos para habilitar la autoevaluación."
}

# =====================================================
# 2. GUARDAR RESPUESTA
# =====================================================
if ($preguntas.Count > 0) {
    Write-Host "`n2. Guardando respuesta..." -ForegroundColor Yellow
    $body = @{
        pregunta_id        = $primeraPregunta.id
        respuesta_numerica = 5 # Asumiendo que es tipo likert
    } | ConvertTo-Json

    try {
        $respuesta = Invoke-RestMethod -Uri "http://localhost:3000/api/autoevaluacion/respuesta" `
            -Method Post `
            -Headers $headers `
            -Body $body
        
        Write-Host "✅ Respuesta guardada exitosamente" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error al guardar respuesta: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =====================================================
# 3. VER PROGRESO
# =====================================================
Write-Host "`n3. Verificando progreso..." -ForegroundColor Yellow
try {
    $progreso = Invoke-RestMethod -Uri "http://localhost:3000/api/autoevaluacion/progreso" `
        -Method Get `
        -Headers $headers
    
    Write-Host "✅ Progreso obtenido:" -ForegroundColor Green
    Write-Host "Total Preguntas: $($progreso.total_preguntas)"
    Write-Host "Respondidas: $($progreso.preguntas_respondidas)"
    Write-Host "Porcentaje: $($progreso.porcentaje_completado)%"
}
catch {
    Write-Host "❌ Error al obtener progreso: $($_.Exception.Message)" -ForegroundColor Red
}
