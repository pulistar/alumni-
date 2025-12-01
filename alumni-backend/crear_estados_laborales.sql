-- ============================================
-- MIGRACIÓN SIMPLIFICADA: Crear tabla estados_laborales
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

-- 1. Crear tabla de estados laborales
CREATE TABLE IF NOT EXISTS public.estados_laborales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    orden INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Insertar opciones predefinidas
INSERT INTO public.estados_laborales (nombre, descripcion, orden) VALUES
    ('Empleado', 'Trabajando en relación de dependencia', 1),
    ('Independiente', 'Trabajador independiente o freelance', 2),
    ('Empresario', 'Dueño de empresa o emprendedor', 3),
    ('Desempleado', 'Buscando empleo activamente', 4),
    ('Estudiando', 'Cursando estudios de posgrado o especialización', 5),
    ('Otro', 'Otra situación laboral', 6)
ON CONFLICT (nombre) DO NOTHING;

-- 3. Agregar nueva columna estado_laboral_id
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS estado_laboral_id UUID REFERENCES public.estados_laborales(id);

-- 4. Migrar datos existentes (si hay datos con estado_laboral)
UPDATE public.egresados e
SET estado_laboral_id = el.id
FROM public.estados_laborales el
WHERE LOWER(TRIM(COALESCE(e.estado_laboral, ''))) = LOWER(el.nombre);

-- Asignar "Otro" a los que no coincidan pero tienen valor
UPDATE public.egresados e
SET estado_laboral_id = (SELECT id FROM public.estados_laborales WHERE nombre = 'Otro')
WHERE estado_laboral IS NOT NULL 
  AND estado_laboral != ''
  AND estado_laboral_id IS NULL;

-- 5. Crear índice para la nueva columna
CREATE INDEX IF NOT EXISTS idx_egresados_estado_laboral_id 
ON public.egresados(estado_laboral_id);

-- 6. RLS para estados_laborales
ALTER TABLE public.estados_laborales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Estados laborales son públicos"
ON public.estados_laborales FOR SELECT
TO authenticated, anon
USING (activo = true);

-- 7. Permisos
GRANT SELECT ON public.estados_laborales TO authenticated, anon;
GRANT ALL ON public.estados_laborales TO service_role;

-- 8. Verificación
SELECT 'Tabla estados_laborales creada' AS resultado,
       (SELECT COUNT(*) FROM public.estados_laborales) AS total_estados;

SELECT 'Egresados con estado laboral' AS info,
       COUNT(*) AS total
FROM public.egresados
WHERE estado_laboral_id IS NOT NULL;
