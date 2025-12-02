-- ============================================
-- MIGRACIÓN: Crear tabla estados_laborales y agregar relación
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

-- 1. Crear tabla de estados laborales
CREATE TABLE IF NOT EXISTS public.estados_laborales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    orden INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Insertar estados laborales predefinidos
INSERT INTO public.estados_laborales (nombre, descripcion, orden) VALUES
    ('Empleado', 'Trabajando en relación de dependencia', 1),
    ('Independiente', 'Trabajador independiente o freelance', 2),
    ('Empresario', 'Dueño de empresa o emprendedor', 3),
    ('Desempleado', 'Buscando empleo activamente', 4),
    ('Estudiando', 'Cursando estudios de posgrado o especialización', 5),
    ('Otro', 'Otra situación laboral', 6)
ON CONFLICT (nombre) DO NOTHING;

-- 3. Agregar columna estado_laboral_id a tabla egresados
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS estado_laboral_id UUID;

-- 4. Crear la foreign key
ALTER TABLE public.egresados
ADD CONSTRAINT fk_egresados_estado_laboral 
FOREIGN KEY (estado_laboral_id) 
REFERENCES public.estados_laborales(id)
ON DELETE SET NULL;

-- 5. Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_egresados_estado_laboral_id 
ON public.egresados(estado_laboral_id);

-- 6. Habilitar RLS en estados_laborales
ALTER TABLE public.estados_laborales ENABLE ROW LEVEL SECURITY;

-- 7. Crear política para que todos puedan leer los estados
DROP POLICY IF EXISTS "Estados laborales públicos" ON public.estados_laborales;
CREATE POLICY "Estados laborales públicos"
ON public.estados_laborales FOR SELECT
TO authenticated, anon
USING (activo = true);

-- 8. Dar permisos
GRANT SELECT ON public.estados_laborales TO authenticated, anon;
GRANT ALL ON public.estados_laborales TO service_role;

-- 9. Verificación - Mostrar resultados
SELECT 'Tabla estados_laborales creada exitosamente' AS mensaje,
       (SELECT COUNT(*) FROM public.estados_laborales) AS total_estados;

SELECT 'Columna estado_laboral_id agregada a egresados' AS mensaje;

-- Mostrar los estados laborales creados
SELECT * FROM public.estados_laborales ORDER BY orden;
