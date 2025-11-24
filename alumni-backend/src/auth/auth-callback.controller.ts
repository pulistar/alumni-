import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';

@Controller('auth')
export class AuthCallbackController {
  @Get('callback')
  async handleCallback(@Res() res: Response) {
    // Supabase envía el token en el fragmento (#), no en query params
    // Por eso usamos JavaScript del lado del cliente para capturarlo
    return res.send(`
      <html>
        <head>
          <title>Autenticación</title>
          <style>
            body { 
              font-family: Arial, sans-serif; 
              padding: 40px; 
              background: #f5f5f5; 
              margin: 0;
            }
            .container { 
              max-width: 800px; 
              margin: 0 auto; 
              background: white; 
              padding: 30px; 
              border-radius: 8px; 
              box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
            }
            h1 { color: #003366; margin-top: 0; }
            .success { color: #28a745; }
            .error { color: #dc3545; }
            .token-box { 
              background: #f0f0f0; 
              padding: 15px; 
              border-radius: 5px; 
              word-break: break-all; 
              margin: 20px 0;
              font-family: monospace;
              font-size: 12px;
            }
            button { 
              background: #003366; 
              color: white; 
              padding: 12px 24px; 
              border: none; 
              border-radius: 5px; 
              cursor: pointer;
              font-size: 16px;
              margin-right: 10px;
            }
            button:hover { background: #005599; }
            .loading { text-align: center; padding: 40px; }
            .spinner {
              border: 4px solid #f3f3f3;
              border-top: 4px solid #003366;
              border-radius: 50%;
              width: 40px;
              height: 40px;
              animation: spin 1s linear infinite;
              margin: 0 auto;
            }
            @keyframes spin {
              0% { transform: rotate(0deg); }
              100% { transform: rotate(360deg); }
            }
            code {
              background: #e9ecef;
              padding: 2px 6px;
              border-radius: 3px;
              font-family: monospace;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div id="loading" class="loading">
              <div class="spinner"></div>
              <p>Procesando autenticación...</p>
            </div>
            <div id="content" style="display: none;">
              <h1 id="title"></h1>
              <div id="message"></div>
            </div>
          </div>
          <script>
            // Supabase envía el token en el fragmento (#) de la URL
            const hash = window.location.hash.substring(1);
            const params = new URLSearchParams(hash);
            
            const accessToken = params.get('access_token');
            const refreshToken = params.get('refresh_token');
            const error = params.get('error');
            const errorDescription = params.get('error_description');
            
            const loading = document.getElementById('loading');
            const content = document.getElementById('content');
            const title = document.getElementById('title');
            const message = document.getElementById('message');
            
            loading.style.display = 'none';
            content.style.display = 'block';
            
            if (error) {
              title.innerHTML = '❌ Error de Autenticación';
              title.className = 'error';
              message.innerHTML = \`
                <p><strong>Error:</strong> \${error}</p>
                <p>\${errorDescription || 'Intenta solicitar el Magic Link nuevamente.'}</p>
                <p style="margin-top: 20px;">
                  <strong>Posibles causas:</strong>
                  <ul>
                    <li>El enlace expiró (válido por 1 hora)</li>
                    <li>El enlace ya fue usado</li>
                    <li>Hubo un problema con la configuración</li>
                  </ul>
                </p>
              \`;
            } else if (!accessToken) {
              title.innerHTML = '⚠️ Token No Encontrado';
              message.innerHTML = \`
                <p>No se recibió el token de acceso.</p>
                <p>Esto puede ocurrir si:</p>
                <ul>
                  <li>El enlace no es válido</li>
                  <li>Ya usaste este enlace antes</li>
                </ul>
                <p style="margin-top: 20px;">
                  <strong>Solución:</strong> Solicita un nuevo Magic Link desde el backend.
                </p>
              \`;
            } else {
              title.innerHTML = '✅ Autenticación Exitosa';
              title.className = 'success';
              message.innerHTML = \`
                <p>Tu token de acceso es:</p>
                <div class="token-box" id="token">\${accessToken}</div>
                <button onclick="copyToken()">📋 Copiar Token</button>
                <button onclick="testToken()">🧪 Probar Token</button>
                <p style="margin-top: 30px; color: #666;">
                  <strong>Cómo usar:</strong><br>
                  Usa este token en el header <code>Authorization: Bearer TOKEN</code> para llamar a los endpoints protegidos.
                </p>
                <div id="test-result" style="margin-top: 20px;"></div>
              \`;
            }
            
            function copyToken() {
              const token = document.getElementById('token').innerText;
              navigator.clipboard.writeText(token).then(() => {
                alert('✅ Token copiado al portapapeles!');
              }).catch(() => {
                alert('❌ Error al copiar. Selecciona y copia manualmente.');
              });
            }
            
            async function testToken() {
              const token = document.getElementById('token').innerText;
              const resultDiv = document.getElementById('test-result');
              resultDiv.innerHTML = '<p>Probando token...</p>';
              
              try {
                const response = await fetch('/api/egresados/me', {
                  headers: {
                    'Authorization': 'Bearer ' + token
                  }
                });
                
                if (response.ok) {
                  const data = await response.json();
                  resultDiv.innerHTML = \`
                    <div style="background: #d4edda; padding: 15px; border-radius: 5px; border-left: 4px solid #28a745;">
                      <strong>✅ Token válido!</strong><br>
                      Usuario: \${data.correo || 'N/A'}
                    </div>
                  \`;
                } else if (response.status === 404) {
                  resultDiv.innerHTML = \`
                    <div style="background: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107;">
                      <strong>⚠️ Token válido pero perfil no encontrado</strong><br>
                      Necesitas completar tu perfil llamando a <code>POST /api/egresados/completar-perfil</code>
                    </div>
                  \`;
                } else {
                  resultDiv.innerHTML = \`
                    <div style="background: #f8d7da; padding: 15px; border-radius: 5px; border-left: 4px solid #dc3545;">
                      <strong>❌ Error:</strong> \${response.status} - \${response.statusText}
                    </div>
                  \`;
                }
              } catch (error) {
                resultDiv.innerHTML = \`
                  <div style="background: #f8d7da; padding: 15px; border-radius: 5px; border-left: 4px solid #dc3545;">
                    <strong>❌ Error de conexión:</strong> \${error.message}
                  </div>
                \`;
              }
            }
          </script>
        </body>
      </html>
    `);
  }
}
