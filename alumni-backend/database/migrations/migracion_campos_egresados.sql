-- ============================================
-- MIGRACIÓN: Actualización de Campos en Tabla Egresados
-- ============================================
-- Este script actualiza la estructura de la tabla egresados para alinearla
-- con el formato oficial del Excel de la universidad
--
-- INSTRUCCIONES:
-- 1. Haz backup de tu base de datos antes de ejecutar
-- 2. Ve a Supabase → SQL Editor
-- 3. Copia y pega este script completo
-- 4. Ejecuta
-- ============================================

-- ============================================
-- PASO 1: Crear tabla de Tipos de Documento
-- ============================================
CREATE TABLE IF NOT EXISTS public.tipos_documento (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    para_colombianos BOOLEAN DEFAULT true,
    para_extranjeros BOOLEAN DEFAULT false,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.tipos_documento IS 'Catálogo de tipos de documento de identidad válidos en Colombia';
COMMENT ON COLUMN public.tipos_documento.para_colombianos IS 'Indica si este tipo de documento es válido para ciudadanos colombianos';
COMMENT ON COLUMN public.tipos_documento.para_extranjeros IS 'Indica si este tipo de documento es válido para extranjeros';

-- Insertar tipos de documento
INSERT INTO public.tipos_documento (codigo, nombre, descripcion, para_colombianos, para_extranjeros) VALUES
    -- Documentos para colombianos
    ('CC', 'Cédula de Ciudadanía', 'Documento de identidad para ciudadanos colombianos mayores de 18 años', true, false),
    ('TI', 'Tarjeta de Identidad', 'Documento de identidad para menores de edad colombianos', true, false),
    ('RC', 'Registro Civil', 'Documento de identidad para niños menores de 7 años', true, false),
    
    -- Documentos para extranjeros
    ('CE', 'Cédula de Extranjería', 'Documento de identidad para extranjeros residentes en Colombia', false, true),
    ('PA', 'Pasaporte', 'Documento de viaje internacional', true, true),
    ('PEP', 'Permiso Especial de Permanencia', 'Documento para migrantes venezolanos', false, true),
    ('PPT', 'Permiso por Protección Temporal', 'Estatuto Temporal de Protección para migrantes venezolanos', false, true),
    
    -- Otros documentos
    ('NIT', 'Número de Identificación Tributaria', 'Identificación tributaria', true, true),
    ('DIE', 'Documento de Identificación Extranjero', 'Otros documentos de identificación extranjeros', false, true),
    ('SC', 'Salvoconducto', 'Documento temporal de identificación', true, true)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- PASO 2: Crear tabla de Grados Académicos
-- ============================================
CREATE TABLE IF NOT EXISTS public.grados_academicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(20) UNIQUE,
    nivel INTEGER, -- 1=Auxiliar, 2=Técnico, 3=Tecnólogo, 4=Pregrado, 5=Especialización, 6=Maestría, 7=Doctorado
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.grados_academicos IS 'Catálogo de grados académicos disponibles';
COMMENT ON COLUMN public.grados_academicos.nivel IS 'Nivel jerárquico del grado académico';

-- Insertar datos iniciales
INSERT INTO public.grados_academicos (nombre, codigo, nivel) VALUES
    ('Auxiliar', 'AUX', 1),
    ('Técnico Profesional', 'TEC', 2),
    ('Tecnólogo', 'TECN', 3),
    ('Pregrado', 'PREG', 4),
    ('Especialización', 'ESP', 5),
    ('Maestría', 'MAES', 6),
    ('Doctorado', 'DOC', 7),
    ('Curso', 'CURSO', 0)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- PASO 3: Agregar nuevas columnas a egresados
-- ============================================

-- Campos de documento de identidad
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS tipo_documento_id UUID REFERENCES public.tipos_documento(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS documento VARCHAR(50),
ADD COLUMN IF NOT EXISTS lugar_expedicion VARCHAR(100);

-- Correo personal (el actual 'correo' será renombrado a 'correo_institucional')
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS correo_personal VARCHAR(255);

-- Relación con grado académico
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS grado_academico_id UUID REFERENCES public.grados_academicos(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.egresados.tipo_documento_id IS 'Tipo de documento de identidad (relación con tipos_documento)';
COMMENT ON COLUMN public.egresados.documento IS 'Número de documento de identidad';
COMMENT ON COLUMN public.egresados.lugar_expedicion IS 'Ciudad/Departamento de expedición del documento';
COMMENT ON COLUMN public.egresados.correo_personal IS 'Correo electrónico personal del egresado';
COMMENT ON COLUMN public.egresados.grado_academico_id IS 'Tipo de grado académico obtenido';

-- ============================================
-- PASO 4: Eliminar vistas temporales
-- ============================================
-- Las vistas dependen de las columnas que vamos a modificar/eliminar

DROP VIEW IF EXISTS public.v_egresados_activos CASCADE;
DROP VIEW IF EXISTS public.v_egresados_completo CASCADE;

-- ============================================
-- PASO 5: Renombrar columnas existentes
-- ============================================

-- Renombrar 'correo' a 'correo_institucional'
ALTER TABLE public.egresados 
RENAME COLUMN correo TO correo_institucional;

-- Renombrar 'telefono' a 'celular'
ALTER TABLE public.egresados 
RENAME COLUMN telefono TO celular;

-- Actualizar comentarios
COMMENT ON COLUMN public.egresados.correo_institucional IS 'Correo institucional @campusucc.edu.co';
COMMENT ON COLUMN public.egresados.celular IS 'Número de celular principal';

-- ============================================
-- PASO 6: Eliminar columnas innecesarias
-- ============================================
-- Estas columnas se capturarán en la autoevaluación, no en el perfil base
-- CASCADE eliminará automáticamente todas las vistas que dependan de estas columnas

ALTER TABLE public.egresados 
DROP COLUMN IF EXISTS pais CASCADE,
DROP COLUMN IF EXISTS ciudad CASCADE,
DROP COLUMN IF EXISTS direccion CASCADE;

-- ============================================
-- PASO 7: Recrear vista con estructura actualizada
-- ============================================

CREATE OR REPLACE VIEW public.v_egresados_activos AS
SELECT 
    e.id,
    e.uid,
    e.correo_institucional,
    e.nombre,
    e.apellido,
    e.id_universitario,
    e.carrera_id,
    c.nombre as carrera_nombre,
    e.celular,
    e.telefono_alternativo,
    e.correo_personal,
    e.tipo_documento_id,
    e.documento,
    e.lugar_expedicion,
    e.grado_academico_id,
    e.habilitado,
    e.proceso_grado_completo,
    e.autoevaluacion_habilitada,
    e.autoevaluacion_completada,
    e.fecha_habilitacion,
    e.habilitado_por,
    e.estado_laboral,
    e.empresa_actual,
    e.cargo_actual,
    e.fecha_graduacion,
    e.semestre_graduacion,
    e.anio_ingreso,
    e.anio_graduacion,
    e.created_at,
    e.updated_at
FROM public.egresados e
LEFT JOIN public.carreras c ON e.carrera_id = c.id
WHERE e.deleted_at IS NULL;

COMMENT ON VIEW public.v_egresados_activos IS 'Vista de egresados activos (no eliminados) con información de carrera';

-- ============================================
-- PASO 8: Actualizar índices
-- ============================================

-- Eliminar índice antiguo de 'correo' si existe
DROP INDEX IF EXISTS idx_egresados_correo;

-- Crear nuevo índice para 'correo_institucional'
CREATE INDEX IF NOT EXISTS idx_egresados_correo_institucional ON public.egresados(correo_institucional);

-- Crear índice para documento
CREATE INDEX IF NOT EXISTS idx_egresados_documento ON public.egresados(documento);

-- Crear índice para tipo de documento
CREATE INDEX IF NOT EXISTS idx_egresados_tipo_documento ON public.egresados(tipo_documento_id);

-- Crear índice para grado académico
CREATE INDEX IF NOT EXISTS idx_egresados_grado_academico ON public.egresados(grado_academico_id);

-- ============================================
-- PASO 9: Actualizar constraint UNIQUE
-- ============================================

-- El constraint UNIQUE de 'correo' se renombra automáticamente,
-- pero vamos a asegurarnos de que existe para correo_institucional
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'egresados_correo_institucional_key'
    ) THEN
        ALTER TABLE public.egresados 
        ADD CONSTRAINT egresados_correo_institucional_key UNIQUE (correo_institucional);
    END IF;
END $$;

-- ============================================
-- PASO 10: Actualizar trigger de validación de correo
-- ============================================

-- Actualizar la función de validación para usar el nuevo nombre de columna
CREATE OR REPLACE FUNCTION validar_correo_institucional()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.correo_institucional NOT LIKE '%@campusucc.edu.co' THEN
    RAISE EXCEPTION 'Solo se permiten correos institucionales @campusucc.edu.co';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger ya existe, solo necesitamos asegurarnos de que apunta a la función correcta
DROP TRIGGER IF EXISTS validar_correo_egresado ON public.egresados;
CREATE TRIGGER validar_correo_egresado
  BEFORE INSERT OR UPDATE ON public.egresados
  FOR EACH ROW
  EXECUTE FUNCTION validar_correo_institucional();

-- ============================================
-- PASO 11: Actualizar políticas RLS (si existen)
-- ============================================

-- Recrear la política de SELECT para egresados con el nuevo nombre de columna
DROP POLICY IF EXISTS "Egresados pueden ver su propia información" ON public.egresados;

CREATE POLICY "Egresados pueden ver su propia información"
    ON public.egresados FOR SELECT
    USING (auth.uid()::text = uid AND deleted_at IS NULL);

-- Recrear la política de UPDATE para egresados
DROP POLICY IF EXISTS "Egresados pueden actualizar su propia información" ON public.egresados;

CREATE POLICY "Egresados pueden actualizar su propia información"
    ON public.egresados FOR UPDATE
    USING (auth.uid()::text = uid AND deleted_at IS NULL)
    WITH CHECK (auth.uid()::text = uid AND deleted_at IS NULL);

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Consulta para verificar la estructura actualizada
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'egresados' 
    AND table_schema = 'public'
ORDER BY ordinal_position;

-- Consulta para verificar los grados académicos insertados
SELECT * FROM public.grados_academicos ORDER BY nivel;

-- ============================================
-- NOTAS IMPORTANTES
-- ============================================
-- 1. Después de ejecutar este script, deberás actualizar tu código backend (NestJS)
--    para usar los nuevos nombres de columnas:
--    - 'correo' → 'correo_institucional'
--    - 'telefono' → 'celular'
--
-- 2. También deberás actualizar tu app Flutter para reflejar estos cambios
--
-- 3. Si tienes datos existentes, considera ejecutar un UPDATE para migrar
--    valores de 'id_universitario' a 'documento' si es necesario
--
-- 4. El campo 'tipo_documento' debería validarse con un CHECK constraint
--    si quieres restringir los valores permitidos (CC, TI, CE, PA, etc.)
-- ============================================
