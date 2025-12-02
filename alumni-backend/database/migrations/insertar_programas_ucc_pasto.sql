-- ============================================
-- SCRIPT: Insertar Programas Académicos UCC Pasto
-- ============================================
-- Este script inserta todos los programas académicos que ofrece
-- la Universidad Cooperativa de Colombia - Sede Pasto
--
-- INSTRUCCIONES:
-- 1. Ve a Supabase → SQL Editor
-- 2. Copia y pega este script
-- 3. Ejecuta
-- ============================================

DO $$
DECLARE
    pregrado_id UUID;
    especializacion_id UUID;
    maestria_id UUID;
    tecnico_id UUID;
BEGIN
    -- Obtener IDs de los grados académicos
    SELECT id INTO pregrado_id FROM public.grados_academicos WHERE nombre = 'Pregrado' LIMIT 1;
    SELECT id INTO especializacion_id FROM public.grados_academicos WHERE nombre = 'Especialización' LIMIT 1;
    SELECT id INTO maestria_id FROM public.grados_academicos WHERE nombre = 'Maestría' LIMIT 1;
    SELECT id INTO tecnico_id FROM public.grados_academicos WHERE nombre = 'Técnico Profesional' LIMIT 1;

    -- ============================================
    -- PROGRAMAS DE PREGRADO
    -- ============================================
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Enfermería', 'ENF', pregrado_id, true),
        ('Derecho', 'DER', pregrado_id, true),
        ('Ingeniería Industrial', 'ING-IND', pregrado_id, true),
        ('Medicina', 'MED', pregrado_id, true),
        ('Odontología', 'ODO', pregrado_id, true),
        ('Ingeniería de Software', 'ING-SOF', pregrado_id, true)
    ON CONFLICT (nombre) DO NOTHING;

    -- ============================================
    -- PROGRAMAS DE ESPECIALIZACIÓN
    -- ============================================
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Especialización en Periodoncia', 'ESP-PER', especializacion_id, true),
        ('Especialización en Producción y Comercio del Café', 'ESP-CAF', especializacion_id, true),
        ('Especialización en Derecho Médico', 'ESP-DM', especializacion_id, true),
        ('Especialización en Endodoncia', 'ESP-END', especializacion_id, true),
        ('Especialización en Medicina Interna', 'ESP-MI', especializacion_id, true),
        ('Especialización en Ortodoncia', 'ESP-ORT', especializacion_id, true),
        ('Especialización en Propiedad Intelectual', 'ESP-PI', especializacion_id, true),
        ('Especialización en Psiquiatría', 'ESP-PSI', especializacion_id, true)
    ON CONFLICT (nombre) DO NOTHING;

    -- ============================================
    -- PROGRAMAS DE MAESTRÍA
    -- ============================================
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Maestría en Derechos Humanos y Gobernanza', 'MAE-DDHH', maestria_id, true)
    ON CONFLICT (nombre) DO NOTHING;

    -- ============================================
    -- PROGRAMAS TÉCNICOS
    -- ============================================
    INSERT INTO public.carreras (nombre, codigo, grado_academico_id, activa) VALUES
        ('Técnico Laboral en Auxiliar en Enfermería', 'TEC-ENF', tecnico_id, true)
    ON CONFLICT (nombre) DO NOTHING;

    RAISE NOTICE 'Programas académicos de UCC Pasto insertados exitosamente';
END $$;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver todos los programas agrupados por grado académico
SELECT 
    g.nombre as grado_academico,
    g.nivel,
    COUNT(c.id) as total_programas,
    STRING_AGG(c.nombre, ', ' ORDER BY c.nombre) as programas
FROM public.grados_academicos g
LEFT JOIN public.carreras c ON c.grado_academico_id = g.id
WHERE c.activa = true
GROUP BY g.id, g.nombre, g.nivel
ORDER BY g.nivel;

-- Ver lista detallada de todos los programas
SELECT 
    c.nombre as programa,
    c.codigo,
    g.nombre as grado_academico,
    c.activa
FROM public.carreras c
LEFT JOIN public.grados_academicos g ON c.grado_academico_id = g.id
ORDER BY g.nivel, c.nombre;
