$token = "eyJhbGciOiJIUzI1NiIsImtpZCI6IjI2REg3M29QUXNUblc3RkEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2NxdW1kcWdyY2JycWxybXNmc3dnLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI0YTMwZTljZi1mNTlmLTQwNjYtYTgyOS01ZDliYzM4ZjhhYTAiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzYzOTU2NTU5LCJpYXQiOjE3NjM5NTI5NTksImVtYWlsIjoiY2FtaWxvLnB1bGlzdGFyQGNhbXB1c3VjYy5lZHUuY28iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoiY2FtaWxvLnB1bGlzdGFyQGNhbXB1c3VjYy5lZHUuY28iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJzdWIiOiI0YTMwZTljZi1mNTlmLTQwNjYtYTgyOS01ZDliYzM4ZjhhYTAifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvdHAiLCJ0aW1lc3RhbXAiOjE3NjM5NTI5NTl9XSwic2Vzc2lvbl9pZCI6IjVkOTViODE0LTA4Y2ItNGE4NC05ZjQxLTA0OGNlNWMwZjAwZCIsImlzX2Fub255bW91cyI6ZmFsc2V9.yZE-5bkX0xq9EyRWDBJT_Ld9OKeJZW_TL0cnyjNfsgU"

$headers = @{
    "Authorization" = "Bearer $token"
}

$filePath = "test-documento.pdf"

$form = @{
    file           = Get-Item -Path $filePath
    tipo_documento = "momento_ole"
}

Write-Host "Subiendo documento..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/documentos/upload" -Method Post -Headers $headers -Form $form
    Write-Host "✅ Documento subido exitosamente!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "❌ Error al subir documento:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host $_.ErrorDetails.Message
}
