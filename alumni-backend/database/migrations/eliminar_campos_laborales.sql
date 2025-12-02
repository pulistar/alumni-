-- ============================================
-- SCRIPT ADICIONAL: Eliminar campos laborales y académicos
-- ============================================
-- Estos campos se capturarán en la autoevaluación, no en el perfil base
--
-- INSTRUCCIONES:
-- 1. Ve a Supabase → SQL Editor
-- 2. Copia y pega este script
-- 3. Ejecuta
-- ============================================

-- Eliminar cualquier vista que pueda depender de estas columnas
DROP VIEW IF EXISTS public.v_egresados_activos CASCADE;
DROP VIEW IF EXISTS public.v_egresados_completo CASCADE;

-- Eliminar columnas de información laboral
ALTER TABLE public.egresados 
DROP COLUMN IF EXISTS estado_laboral_id CASCADE,
DROP COLUMN IF EXISTS estado_laboral CASCADE,
DROP COLUMN IF EXISTS empresa_actual CASCADE,
DROP COLUMN IF EXISTS cargo_actual CASCADE;

-- Eliminar columnas de información académica
ALTER TABLE public.egresados 
DROP COLUMN IF EXISTS fecha_graduacion CASCADE,
DROP COLUMN IF EXISTS semestre_graduacion CASCADE,
DROP COLUMN IF EXISTS anio_ingreso CASCADE,
DROP COLUMN IF EXISTS anio_graduacion CASCADE;

-- Recrear la vista v_egresados_activos sin las columnas eliminadas
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
    e.created_at,
    e.updated_at
FROM public.egresados e
LEFT JOIN public.carreras c ON e.carrera_id = c.id
WHERE e.deleted_at IS NULL;

COMMENT ON VIEW public.v_egresados_activos IS 'Vista de egresados activos (no eliminados) con información de carrera';

-- Verificar la estructura actualizada
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'egresados' 
    AND table_schema = 'public'
ORDER BY ordinal_position;
