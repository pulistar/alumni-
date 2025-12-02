-- ============================================
-- SCRIPT: Agregar grado académico a carreras
-- ============================================
-- Este script modifica la tabla carreras para asociar cada carrera
-- con un grado académico (Pregrado, Maestría, Doctorado, etc.)
--
-- INSTRUCCIONES:
-- 1. Ve a Supabase → SQL Editor
-- 2. Copia y pega este script
-- 3. Ejecuta
-- ============================================

-- ============================================
-- PASO 1: Agregar columna grado_academico_id a carreras
-- ============================================

ALTER TABLE public.carreras 
ADD COLUMN IF NOT EXISTS grado_academico_id UUID REFERENCES public.grados_academicos(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.carreras.grado_academico_id IS 'Nivel académico de la carrera (Pregrado, Maestría, Doctorado, etc.)';

-- Crear índice para búsquedas por grado académico
CREATE INDEX IF NOT EXISTS idx_carreras_grado_academico ON public.carreras(grado_academico_id);

-- ============================================
-- PASO 2: Obtener el ID de Pregrado
-- ============================================

DO $$
DECLARE
    pregrado_id UUID;
BEGIN
    -- Obtener el ID del grado académico "Pregrado"
    SELECT id INTO pregrado_id 
    FROM public.grados_academicos 
    WHERE nombre = 'Pregrado' 
    LIMIT 1;

    -- Actualizar todas las carreras existentes como Pregrado
    IF pregrado_id IS NOT NULL THEN
        UPDATE public.carreras 
        SET grado_academico_id = pregrado_id
        WHERE grado_academico_id IS NULL;
        
        RAISE NOTICE 'Todas las carreras existentes han sido marcadas como Pregrado';
    ELSE
        RAISE WARNING 'No se encontró el grado académico "Pregrado". Asegúrate de haber ejecutado el script de migración primero.';
    END IF;
END $$;

-- ============================================
-- PASO 3: Ejemplos de cómo agregar carreras de posgrado
-- ============================================

-- Primero, obtener los IDs de los grados académicos
DO $$
DECLARE
    maestria_id UUID;
    doctorado_id UUID;
    especializacion_id UUID;
BEGIN
    -- Obtener IDs
    SELECT id INTO maestria_id FROM public.grados_academicos WHERE nombre = 'Maestría' LIMIT 1;
    SELECT id INTO doctorado_id FROM public.grados_academicos WHERE nombre = 'Doctorado' LIMIT 1;
    SELECT id INTO especializacion_id FROM public.grados_academicos WHERE nombre = 'Especialización' LIMIT 1;

    -- Insertar ejemplos de maestrías (OPCIONAL - Descomenta si necesitas)
    /*
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Maestría en Administración de Empresas', 'MAE-ADM', maestria_id, true),
        ('Maestría en Educación', 'MAE-EDU', maestria_id, true),
        ('Maestría en Ingeniería', 'MAE-ING', maestria_id, true)
    ON CONFLICT (nombre) DO NOTHING;
    */

    -- Insertar ejemplos de especializaciones (OPCIONAL - Descomenta si necesitas)
    /*
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Especialización en Gerencia de Proyectos', 'ESP-GPR', especializacion_id, true),
        ('Especialización en Derecho Laboral', 'ESP-DLA', especializacion_id, true)
    ON CONFLICT (nombre) DO NOTHING;
    */

    -- Insertar ejemplos de doctorados (OPCIONAL - Descomenta si necesitas)
    /*
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Doctorado en Educación', 'DOC-EDU', doctorado_id, true),
        ('Doctorado en Ciencias Sociales', 'DOC-CSO', doctorado_id, true)
    ON CONFLICT (nombre) DO NOTHING;
    */

    RAISE NOTICE 'Script completado. Descomenta las secciones de INSERT si necesitas agregar carreras de posgrado.';
END $$;

-- ============================================
-- PASO 4: Crear vista para carreras por grado académico
-- ============================================

CREATE OR REPLACE VIEW public.v_carreras_por_grado AS
SELECT 
    c.id,
    c.nombre as carrera_nombre,
    c.codigo as carrera_codigo,
    c.activa,
    g.id as grado_academico_id,
    g.nombre as grado_academico_nombre,
    g.codigo as grado_academico_codigo,
    g.nivel as grado_academico_nivel
FROM public.carreras c
LEFT JOIN public.grados_academicos g ON c.grado_academico_id = g.id
WHERE c.activa = true
ORDER BY g.nivel, c.nombre;

COMMENT ON VIEW public.v_carreras_por_grado IS 'Vista de carreras agrupadas por grado académico';

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Ver todas las carreras con su grado académico
SELECT 
    c.nombre as carrera,
    c.codigo,
    g.nombre as grado_academico,
    g.nivel
FROM public.carreras c
LEFT JOIN public.grados_academicos g ON c.grado_academico_id = g.id
ORDER BY g.nivel, c.nombre;

-- ============================================
-- NOTAS IMPORTANTES
-- ============================================
-- 1. Todas las carreras existentes se marcaron automáticamente como "Pregrado"
-- 
-- 2. Para agregar nuevas carreras de posgrado, usa:
--    INSERT INTO carreras (nombre, codigo, grado_academico_id) VALUES
--    ('Nombre de la Maestría', 'COD-MAE', (SELECT id FROM grados_academicos WHERE nombre = 'Maestría'));
--
-- 3. En tu backend, crea un endpoint para filtrar carreras por grado académico:
--    GET /carreras?grado_academico_id={uuid}
--
-- 4. En la app Flutter, el flujo debe ser:
--    a) Usuario selecciona grado académico (Pregrado, Maestría, etc.)
--    b) Se carga la lista de carreras filtradas por ese grado
--    c) Usuario selecciona su carrera específica
-- ============================================
