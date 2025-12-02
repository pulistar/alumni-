# 🚀 Despliegue Rápido - Alumni Backend

## Opción 1: Despliegue Automático con render.yaml

1. Sube tu código a GitHub
2. En Render.com, selecciona "New > Blueprint"
3. Conecta tu repositorio
4. Render detectará automáticamente `render.yaml`
5. Configura las variables de entorno sensibles en el dashboard
6. Deploy!

## Opción 2: Despliegue Manual

Sigue la guía completa en el archivo de artifacts o en la documentación del proyecto.

## Variables de Entorno Requeridas

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
JWT_SECRET=
JWT_EXPIRATION=7d
NODE_ENV=production
PORT=3000
CORS_ORIGIN=*
```

## URL del Servicio

Después del despliegue, tu backend estará disponible en:
```
https://alumni-backend-xxxx.onrender.com
```

## Health Check

Verifica que el servicio esté funcionando:
```bash
curl https://tu-app.onrender.com/api/health
```

## Documentación API

Si Swagger está habilitado en producción:
```
https://tu-app.onrender.com/api/docs
```
