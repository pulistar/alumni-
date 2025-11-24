-- ============================================
-- MIGRACIÓN: Agregar tabla estados_laborales
-- ============================================
-- Este script convierte el campo estado_laboral de texto a relación con tabla catálogo

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

-- 3. Agregar nueva columna (sin eliminar la antigua todavía)
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS estado_laboral_id UUID REFERENCES public.estados_laborales(id);

-- 4. Migrar datos existentes
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

-- 5. ELIMINAR VISTAS QUE DEPENDEN DE LA COLUMNA
DROP VIEW IF EXISTS public.v_egresados_completo CASCADE;
DROP VIEW IF EXISTS public.v_egresados_activos CASCADE;
DROP VIEW IF EXISTS public.v_estadisticas_laborales CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.mv_estadisticas_dashboard CASCADE;

-- 6. ELIMINAR LA COLUMNA ANTIGUA
ALTER TABLE public.egresados DROP COLUMN IF EXISTS estado_laboral;

-- 7. RECREAR VISTAS CON LA NUEVA ESTRUCTURA

-- Vista completa con JOIN
CREATE OR REPLACE VIEW public.v_egresados_completo AS
SELECT 
    e.id,
    e.uid,
    e.correo,
    e.nombre,
    e.apellido,
    e.id_universitario,
    e.telefono,
    e.ciudad,
    el.nombre AS estado_laboral,
    e.empresa_actual,
    e.cargo_actual,
    c.nombre AS carrera_nombre,
    c.codigo AS carrera_codigo,
    e.habilitado,
    e.proceso_grado_completo,
    e.autoevaluacion_habilitada,
    e.autoevaluacion_completada,
    e.fecha_habilitacion,
    a.nombre AS habilitado_por_nombre,
    (SELECT COUNT(*) FROM public.documentos_egresado WHERE egresado_id = e.id AND es_unificado = false AND deleted_at IS NULL) AS documentos_subidos,
    (SELECT COUNT(*) FROM public.respuestas_autoevaluacion WHERE egresado_id = e.id) AS respuestas_autoevaluacion,
    e.created_at,
    e.updated_at
FROM public.egresados e
LEFT JOIN public.carreras c ON e.carrera_id = c.id
LEFT JOIN public.administradores a ON e.habilitado_por = a.id
LEFT JOIN public.estados_laborales el ON e.estado_laboral_id = el.id
WHERE e.deleted_at IS NULL;

-- Vista de egresados activos
CREATE OR REPLACE VIEW public.v_egresados_activos AS
SELECT 
    e.*,
    el.nombre AS estado_laboral_nombre
FROM public.egresados e
LEFT JOIN public.estados_laborales el ON e.estado_laboral_id = el.id
WHERE e.deleted_at IS NULL;

-- Vista de estadísticas laborales
CREATE OR REPLACE VIEW public.v_estadisticas_laborales AS
SELECT 
    el.nombre AS estado_laboral,
    COUNT(e.id) AS total,
    ROUND(COUNT(e.id) * 100.0 / NULLIF((SELECT COUNT(*) FROM public.egresados WHERE deleted_at IS NULL), 0), 2) AS porcentaje
FROM public.estados_laborales el
LEFT JOIN public.egresados e ON e.estado_laboral_id = el.id AND e.deleted_at IS NULL
GROUP BY el.id, el.nombre, el.orden
ORDER BY el.orden;

-- Vista materializada para dashboard
CREATE MATERIALIZED VIEW public.mv_estadisticas_dashboard AS
SELECT 
    COUNT(*) AS total_egresados,
    COUNT(*) FILTER (WHERE habilitado = true) AS habilitados,
    COUNT(*) FILTER (WHERE proceso_grado_completo = true) AS proceso_completo,
    COUNT(*) FILTER (WHERE autoevaluacion_completada = true) AS autoevaluacion_completa,
    COUNT(DISTINCT carrera_id) AS total_carreras_activas,
    COUNT(*) FILTER (WHERE estado_laboral_id = (SELECT id FROM estados_laborales WHERE nombre = 'Empleado')) AS empleados,
    COUNT(*) FILTER (WHERE estado_laboral_id = (SELECT id FROM estados_laborales WHERE nombre = 'Desempleado')) AS desempleados,
    COUNT(*) FILTER (WHERE estado_laboral_id = (SELECT id FROM estados_laborales WHERE nombre = 'Empresario')) AS emprendedores,
    AVG(CASE WHEN autoevaluacion_completada THEN 
        (SELECT AVG(respuesta_numerica) FROM respuestas_autoevaluacion WHERE egresado_id = egresados.id)
    END) AS promedio_autoevaluacion_general,
    NOW() AS ultima_actualizacion
FROM public.egresados
WHERE deleted_at IS NULL;

-- Índice para la vista materializada
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_dashboard_refresh ON public.mv_estadisticas_dashboard (ultima_actualizacion);

-- 8. Crear índice para la nueva columna
CREATE INDEX IF NOT EXISTS idx_egresados_estado_laboral_id 
ON public.egresados(estado_laboral_id);

-- 9. RLS para estados_laborales
ALTER TABLE public.estados_laborales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Estados laborales son públicos"
ON public.estados_laborales FOR SELECT
TO authenticated, anon
USING (activo = true);

-- 10. Permisos
GRANT SELECT ON public.estados_laborales TO authenticated, anon;
GRANT ALL ON public.estados_laborales TO service_role;

-- 11. Refresh materialized view
REFRESH MATERIALIZED VIEW public.mv_estadisticas_dashboard;

-- 12. Verificación final
SELECT 
    'Estados Laborales' AS tabla,
    COUNT(*) AS total_registros
FROM public.estados_laborales
UNION ALL
SELECT 
    'Egresados con estado laboral' AS tabla,
    COUNT(*) AS total_registros
FROM public.egresados
WHERE estado_laboral_id IS NOT NULL;

-- ============================================
-- MIGRACIÓN COMPLETADA
-- ============================================
SELECT 'Migración completada exitosamente' AS resultado;
