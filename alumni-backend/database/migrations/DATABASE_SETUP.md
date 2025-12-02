# 📚 Guía de Implementación - Base de Datos Alumni

## ✅ Archivo Creado

Se ha generado el archivo `supabase_schema.sql` con el esquema completo de la base de datos.

## 🗄️ Estructura de la Base de Datos

### Tablas Principales (9 tablas)

1. **`carreras`** - Catálogo de carreras del campus
2. **`egresados`** - Información de egresados registrados
3. **`administradores`** - Usuarios administrativos del sistema
4. **`documentos_egresado`** - Evidencias subidas (PDF + imágenes)
5. **`preguntas_autoevaluacion`** - Preguntas configurables del formulario
6. **`respuestas_autoevaluacion`** - Respuestas de los egresados
7. **`cargas_excel`** - Historial de cargas de habilitación
8. **`modulos`** - Los 9 módulos del sistema (solo PreAlumni activo)
9. **`logs_sistema`** - Auditoría de eventos

### Características Implementadas

✅ **Row Level Security (RLS)** - Los egresados solo ven sus propios datos  
✅ **Triggers automáticos** - Actualización de `updated_at`  
✅ **Vistas útiles** - `v_egresados_completo`, `v_estadisticas_autoevaluacion`  
✅ **Funciones PostgreSQL** - `verificar_proceso_completo()`, `obtener_estadisticas_generales()`  
✅ **Índices optimizados** - Para búsquedas frecuentes  
✅ **Datos iniciales** - 8 carreras, 9 módulos, 10 preguntas de ejemplo, 1 admin

## 📋 Pasos para Implementar en Supabase

### 1. Acceder a Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Inicia sesión en tu proyecto
3. Ve a **SQL Editor** en el menú lateral

### 2. Ejecutar el Script

1. Abre el archivo `supabase_schema.sql`
2. Copia **TODO** el contenido
3. Pega en el SQL Editor de Supabase
4. Haz clic en **RUN** o presiona `Ctrl+Enter`

### 3. Verificar la Creación

Al finalizar verás:
- ✅ Mensaje: "Base de datos Alumni creada exitosamente"
- ✅ Tabla con el resumen de las 9 tablas creadas

### 4. Configurar Storage Bucket

**IMPORTANTE**: Los buckets NO se crean automáticamente con SQL.

1. Ve a **Storage** en Supabase
2. Crea un nuevo bucket llamado: `egresados-documentos`
3. Configuración:
   - **Público**: NO ❌
   - **Tamaño máximo**: 10 MB
   - **Tipos permitidos**: `application/pdf`, `image/png`, `image/jpeg`

4. Crea las políticas de Storage:

**Política 1: Subir archivos**
```sql
-- Los egresados pueden subir a su carpeta
CREATE POLICY "Egresados pueden subir archivos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'egresados-documentos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

**Política 2: Leer archivos**
```sql
-- Los egresados pueden leer sus archivos
CREATE POLICY "Egresados pueden leer sus archivos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'egresados-documentos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

**Política 3: Actualizar archivos**
```sql
-- Los egresados pueden actualizar sus archivos
CREATE POLICY "Egresados pueden actualizar archivos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'egresados-documentos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

## 🔐 Configuración de Autenticación

### Supabase Auth para Egresados

1. Ve a **Authentication** → **Providers**
2. Habilita **Email** provider
3. Configura **Magic Link**:
   - ✅ Enable Email Provider
   - ✅ Enable Email Confirmations
   - Configura el template del email con tu dominio institucional

### Restricción de Dominio (Opcional)

Para permitir solo correos `@campusucc.edu.co`, agrega esta función:

```sql
CREATE OR REPLACE FUNCTION public.validar_correo_institucional()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.correo NOT LIKE '%@campusucc.edu.co' THEN
    RAISE EXCEPTION 'Solo se permiten correos institucionales @campusucc.edu.co';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_correo_egresado
  BEFORE INSERT OR UPDATE ON public.egresados
  FOR EACH ROW
  EXECUTE FUNCTION validar_correo_institucional();
```

## 🔑 Credenciales de Administrador

Se creó un administrador de ejemplo:

- **Correo**: `admin@campusucc.edu.co`
- **Password**: `Admin123!` (hash incluido en el script)

> ⚠️ **IMPORTANTE**: Este password es de ejemplo. Debes cambiarlo en producción usando bcrypt desde tu backend NestJS.

## 🏗️ Estructura de Carpetas en Storage

```
egresados-documentos/
└── {uid-del-egresado}/
    ├── momento_ole.pdf
    ├── datos_egresados.png
    ├── bolsa_empleo.png
    └── evidencias_completo.pdf  ← Generado por backend
```

## 📊 Datos Iniciales Incluidos

### Carreras (8)
- Ingeniería de Sistemas
- Administración de Empresas
- Contaduría Pública
- Derecho
- Psicología
- Ingeniería Industrial
- Comunicación Social
- Arquitectura

### Módulos (9)
Solo **PreAlumni** está activo. Los otros 8 están deshabilitados.

### Preguntas de Autoevaluación (10)
Preguntas tipo Likert (1-5) sobre competencias y empleabilidad.

## 🔧 Funciones Útiles

### Verificar proceso completo
```sql
SELECT public.verificar_proceso_completo('uuid-del-egresado');
```

### Obtener estadísticas
```sql
SELECT * FROM public.obtener_estadisticas_generales();
```

### Ver egresados completos
```sql
SELECT * FROM public.v_egresados_completo;
```

### Ver estadísticas de autoevaluación
```sql
SELECT * FROM public.v_estadisticas_autoevaluacion;
```

## 🔒 Seguridad (RLS)

Las políticas RLS garantizan que:

✅ Los egresados solo ven y modifican sus propios datos  
✅ Los egresados solo acceden a sus propios documentos  
✅ Los egresados solo ven sus propias respuestas  
✅ Los administradores usan `service_role_key` para acceso completo

## 🚀 Próximos Pasos

1. ✅ Ejecutar el script SQL en Supabase
2. ⬜ Crear el bucket `egresados-documentos`
3. ⬜ Configurar las políticas de Storage
4. ⬜ Configurar Supabase Auth (Magic Link)
5. ⬜ Obtener las credenciales de Supabase:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY` (para apps Flutter)
   - `SUPABASE_SERVICE_ROLE_KEY` (para backend NestJS)
6. ⬜ Configurar variables de entorno en NestJS
7. ⬜ Implementar los endpoints del backend

## 📝 Notas Importantes

- El campo `uid` en la tabla `egresados` debe coincidir con el `auth.uid()` de Supabase Auth
- Los administradores NO usan Supabase Auth, se autentican con JWT desde NestJS
- El backend debe usar `service_role_key` para operaciones administrativas
- Los documentos originales NO se eliminan al generar el PDF unificado
- La tabla `logs_sistema` registra eventos importantes para auditoría

## 🆘 Soporte

Si encuentras errores al ejecutar el script:

1. Verifica que las extensiones `uuid-ossp` y `pgcrypto` estén habilitadas
2. Asegúrate de ejecutar el script completo de una sola vez
3. Revisa los mensajes de error en el SQL Editor
4. Si hay conflictos, puedes ejecutar `DROP TABLE` antes de volver a crear

---

**¡Base de datos lista para el sistema Alumni! 🎓**
