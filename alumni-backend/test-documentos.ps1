# =====================================================
# Script de Prueba - Módulo de Documentos
# =====================================================
# Este script te ayuda a probar los endpoints de documentos
# usando PowerShell y curl
# =====================================================

# IMPORTANTE: Reemplaza {TOKEN} con tu token de Supabase Auth
# Lo obtuviste cuando hiciste login con Magic Link

$token = "TU_TOKEN_AQUI"

# =====================================================
# 1. SUBIR DOCUMENTO
# =====================================================
# Crea un archivo de prueba primero:
# New-Item -Path "test-documento.pdf" -ItemType File -Force
# Set-Content -Path "test-documento.pdf" -Value "Contenido de prueba"

# Subir con PowerShell:
$headers = @{
    "Authorization" = "Bearer $token"
}

$form = @{
    file = Get-Item -Path "test-documento.pdf"
    tipo_documento = "momento_ole"
}

Invoke-RestMethod -Uri "http://localhost:3000/api/documentos/upload" `
    -Method Post `
    -Headers $headers `
    -Form $form

# =====================================================
# 2. LISTAR DOCUMENTOS
# =====================================================
Invoke-RestMethod -Uri "http://localhost:3000/api/documentos" `
    -Method Get `
    -Headers @{"Authorization" = "Bearer $token"}

# =====================================================
# 3. OBTENER URL DE DESCARGA
# =====================================================
# Reemplaza {ID_DOCUMENTO} con el ID que obtuviste del listado
$documentoId = "ID_DOCUMENTO_AQUI"

Invoke-RestMethod -Uri "http://localhost:3000/api/documentos/$documentoId/download" `
    -Method Get `
    -Headers @{"Authorization" = "Bearer $token"}

# =====================================================
# 4. ELIMINAR DOCUMENTO
# =====================================================
Invoke-RestMethod -Uri "http://localhost:3000/api/documentos/$documentoId" `
    -Method Delete `
    -Headers @{"Authorization" = "Bearer $token"}

# =====================================================
# TIPOS DE DOCUMENTO PERMITIDOS
# =====================================================
# - momento_ole
# - datos_egresados
# - bolsa_empleo
# - otro

# =====================================================
# TIPOS DE ARCHIVO PERMITIDOS
# =====================================================
# - PDF (application/pdf)
# - PNG (image/png)
# - JPG/JPEG (image/jpeg)
# Tamaño máximo: 10MB
