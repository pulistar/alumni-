# Script para generar PDF desde Markdown usando la extensión markdown-pdf de VS Code
$markdownFile = "c:\Users\Public\Documents\Proyecto de Grado\REVISION_PROYECTO_ALUMNI.md"
$pdfFile = "c:\Users\Public\Documents\Proyecto de Grado\REVISION_PROYECTO_ALUMNI.pdf"

Write-Host "Generando PDF desde Markdown..." -ForegroundColor Green
Write-Host "Archivo origen: $markdownFile" -ForegroundColor Cyan
Write-Host "Archivo destino: $pdfFile" -ForegroundColor Cyan

# Intentar generar PDF con markdown-pdf
try {
    # Usar la extensión de VS Code
    code --wait $markdownFile
    
    Write-Host "`nPara generar el PDF:" -ForegroundColor Yellow
    Write-Host "1. Presiona Ctrl+Shift+P en VS Code" -ForegroundColor White
    Write-Host "2. Escribe: 'Markdown PDF: Export (pdf)'" -ForegroundColor White
    Write-Host "3. Presiona Enter" -ForegroundColor White
    Write-Host "`nEl PDF se generará en la misma carpeta con el nombre:" -ForegroundColor Yellow
    Write-Host "REVISION_PROYECTO_ALUMNI.pdf" -ForegroundColor Cyan
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
