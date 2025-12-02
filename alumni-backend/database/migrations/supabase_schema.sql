-- ============================================
-- SISTEMA ALUMNI - SUPABASE POSTGRESQL SCHEMA
-- ============================================
-- Este script crea todas las tablas, políticas RLS, triggers y configuraciones
-- necesarias para el sistema Alumni con NestJS + Supabase + Flutter
--
-- INSTRUCCIONES:
-- 1. Copia todo este código
-- 2. Ve a tu proyecto Supabase → SQL Editor
-- 3. Pega y ejecuta este script
-- ============================================

-- ============================================
-- 1. EXTENSIONES NECESARIAS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 2. TABLAS PRINCIPALES
-- ============================================

-- ============================================
-- 2.1 TABLA: carreras
-- Catálogo de carreras del campus
-- ============================================
CREATE TABLE IF NOT EXISTS public.carreras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(255) NOT NULL UNIQUE,
    codigo VARCHAR(50) UNIQUE,
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.carreras IS 'Catálogo de carreras disponibles en el campus';

-- ============================================
-- 2.2 TABLA: egresados
-- Información de los egresados registrados
-- ============================================
CREATE TABLE IF NOT EXISTS public.egresados (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uid VARCHAR(255) NOT NULL UNIQUE, -- ID de Supabase Auth
    correo VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    id_universitario VARCHAR(100),
    carrera_id UUID REFERENCES public.carreras(id) ON DELETE SET NULL,
    
    -- Campos de contacto (PRIORIDAD ALTA)
    telefono VARCHAR(20),
    telefono_alternativo VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(100),
    pais VARCHAR(100) DEFAULT 'Colombia',
    
    -- Estado del proceso
    habilitado BOOLEAN DEFAULT false,
    proceso_grado_completo BOOLEAN DEFAULT false,
    autoevaluacion_habilitada BOOLEAN DEFAULT false,
    autoevaluacion_completada BOOLEAN DEFAULT false,
    fecha_habilitacion TIMESTAMP WITH TIME ZONE,
    habilitado_por UUID, -- Referencia al admin que habilitó
    
    -- Información laboral (PRIORIDAD MEDIA)
    estado_laboral VARCHAR(50), -- 'empleado', 'desempleado', 'emprendedor', 'estudiando'
    empresa_actual VARCHAR(255),
    cargo_actual VARCHAR(255),
    fecha_graduacion DATE,
    semestre_graduacion VARCHAR(20), -- '2024-1', '2024-2'
    anio_ingreso INTEGER,
    anio_graduacion INTEGER,
    
    -- Soft delete (PRIORIDAD MEDIA)
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.egresados IS 'Información de egresados registrados en el sistema';
COMMENT ON COLUMN public.egresados.uid IS 'ID del usuario en Supabase Auth';
COMMENT ON COLUMN public.egresados.habilitado IS 'Indica si el egresado fue validado por el administrativo';
COMMENT ON COLUMN public.egresados.proceso_grado_completo IS 'Indica si subió todas las evidencias requeridas';
COMMENT ON COLUMN public.egresados.estado_laboral IS 'Estado laboral actual: empleado, desempleado, emprendedor, estudiando';
COMMENT ON COLUMN public.egresados.deleted_at IS 'Fecha de eliminación suave (soft delete). NULL si está activo';

-- Índices para búsquedas frecuentes
CREATE INDEX idx_egresados_correo ON public.egresados(correo);
CREATE INDEX idx_egresados_uid ON public.egresados(uid);
CREATE INDEX idx_egresados_habilitado ON public.egresados(habilitado);
CREATE INDEX idx_egresados_carrera ON public.egresados(carrera_id);
CREATE INDEX idx_egresados_deleted_at ON public.egresados(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_egresados_estado_laboral ON public.egresados(estado_laboral);

-- ============================================
-- 2.3 TABLA: administradores
-- Usuarios administrativos del sistema
-- ============================================
CREATE TABLE IF NOT EXISTS public.administradores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    correo VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    password_hash TEXT NOT NULL, -- Hash bcrypt del password
    rol VARCHAR(50) DEFAULT 'admin', -- admin, superadmin, etc.
    activo BOOLEAN DEFAULT true,
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.administradores IS 'Usuarios administrativos con acceso al panel de gestión';

CREATE INDEX idx_administradores_correo ON public.administradores(correo);

-- ============================================
-- 2.4 TABLA: documentos_egresado
-- Evidencias subidas por los egresados
-- ============================================
CREATE TABLE IF NOT EXISTS public.documentos_egresado (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    egresado_id UUID NOT NULL REFERENCES public.egresados(id) ON DELETE CASCADE,
    tipo_documento VARCHAR(100) NOT NULL, -- 'momento_ole', 'datos_egresados', 'bolsa_empleo', 'evidencias_completo'
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_storage TEXT NOT NULL, -- Ruta en Supabase Storage
    tamano_bytes BIGINT,
    mime_type VARCHAR(100),
    es_unificado BOOLEAN DEFAULT false, -- true si es el PDF generado automáticamente
    deleted_at TIMESTAMP WITH TIME ZONE, -- Soft delete (PRIORIDAD MEDIA)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.documentos_egresado IS 'Documentos y evidencias subidos por los egresados';
COMMENT ON COLUMN public.documentos_egresado.es_unificado IS 'Indica si es el PDF unificado generado por el backend';

CREATE INDEX idx_documentos_egresado_id ON public.documentos_egresado(egresado_id);
CREATE INDEX idx_documentos_tipo ON public.documentos_egresado(tipo_documento);
CREATE INDEX idx_documentos_deleted_at ON public.documentos_egresado(deleted_at) WHERE deleted_at IS NULL;

-- ============================================
-- 2.5 TABLA: preguntas_autoevaluacion
-- Preguntas del formulario de autoevaluación
-- ============================================
CREATE TABLE IF NOT EXISTS public.preguntas_autoevaluacion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    texto TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL DEFAULT 'likert', -- 'likert', 'texto', 'multiple', etc.
    opciones JSONB, -- Para preguntas de selección múltiple
    orden INTEGER NOT NULL,
    categoria VARCHAR(100), -- 'competencias', 'empleabilidad', etc.
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.preguntas_autoevaluacion IS 'Preguntas configurables para la autoevaluación de competencias';
COMMENT ON COLUMN public.preguntas_autoevaluacion.tipo IS 'Tipo de pregunta: likert (1-5), texto, multiple';

CREATE INDEX idx_preguntas_orden ON public.preguntas_autoevaluacion(orden);
CREATE INDEX idx_preguntas_activa ON public.preguntas_autoevaluacion(activa);

-- ============================================
-- 2.6 TABLA: respuestas_autoevaluacion
-- Respuestas de los egresados a la autoevaluación
-- ============================================
CREATE TABLE IF NOT EXISTS public.respuestas_autoevaluacion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    egresado_id UUID NOT NULL REFERENCES public.egresados(id) ON DELETE CASCADE,
    pregunta_id UUID NOT NULL REFERENCES public.preguntas_autoevaluacion(id) ON DELETE CASCADE,
    respuesta_texto TEXT,
    respuesta_numerica INTEGER, -- Para preguntas Likert (1-5)
    respuesta_json JSONB, -- Para respuestas complejas
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(egresado_id, pregunta_id)
);

COMMENT ON TABLE public.respuestas_autoevaluacion IS 'Respuestas de egresados a la autoevaluación de competencias';

CREATE INDEX idx_respuestas_egresado ON public.respuestas_autoevaluacion(egresado_id);
CREATE INDEX idx_respuestas_pregunta ON public.respuestas_autoevaluacion(pregunta_id);

-- ============================================
-- 2.7 TABLA: cargas_excel
-- Historial de cargas de Excel de habilitación
-- ============================================
CREATE TABLE IF NOT EXISTS public.cargas_excel (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES public.administradores(id) ON DELETE CASCADE,
    nombre_archivo VARCHAR(255) NOT NULL,
    total_registros INTEGER NOT NULL,
    registros_procesados INTEGER NOT NULL,
    registros_habilitados INTEGER NOT NULL,
    registros_errores INTEGER DEFAULT 0,
    errores_detalle JSONB, -- Detalles de errores encontrados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.cargas_excel IS 'Historial de cargas de Excel para habilitar egresados';

CREATE INDEX idx_cargas_admin ON public.cargas_excel(admin_id);
CREATE INDEX idx_cargas_fecha ON public.cargas_excel(created_at);

-- ============================================
-- 2.8 TABLA: modulos
-- Los 9 módulos del sistema (solo PreAlumni activo inicialmente)
-- ============================================
CREATE TABLE IF NOT EXISTS public.modulos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    icono VARCHAR(100), -- Nombre del icono para la app
    orden INTEGER NOT NULL,
    activo BOOLEAN DEFAULT false, -- Solo PreAlumni será true
    url_info TEXT, -- URL con información adicional
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.modulos IS 'Los 9 módulos del sistema Alumni';

-- ============================================
-- 2.9 TABLA: logs_sistema
-- Registro de eventos importantes del sistema
-- ============================================
CREATE TABLE IF NOT EXISTS public.logs_sistema (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tipo VARCHAR(100) NOT NULL, -- 'login', 'habilitacion', 'carga_documento', etc.
    usuario_id UUID, -- Puede ser egresado o admin
    usuario_tipo VARCHAR(50), -- 'egresado' o 'admin'
    accion TEXT NOT NULL,
    detalles JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT, -- PRIORIDAD BAJA
    dispositivo VARCHAR(100), -- PRIORIDAD BAJA
    resultado VARCHAR(50), -- 'exito', 'error' - PRIORIDAD BAJA
    tiempo_ejecucion_ms INTEGER, -- PRIORIDAD BAJA
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.logs_sistema IS 'Registro de auditoría de eventos del sistema';

CREATE INDEX idx_logs_tipo ON public.logs_sistema(tipo);
CREATE INDEX idx_logs_usuario ON public.logs_sistema(usuario_id);
CREATE INDEX idx_logs_fecha ON public.logs_sistema(created_at);
CREATE INDEX idx_logs_resultado ON public.logs_sistema(resultado);

-- ============================================
-- 2.10 TABLA: notificaciones (PRIORIDAD ALTA)
-- Sistema de notificaciones in-app para egresados
-- ============================================
CREATE TABLE IF NOT EXISTS public.notificaciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    egresado_id UUID NOT NULL REFERENCES public.egresados(id) ON DELETE CASCADE,
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50), -- 'habilitacion', 'documento', 'autoevaluacion', 'general'
    leida BOOLEAN DEFAULT false,
    url_accion TEXT, -- URL o ruta para navegar al hacer clic
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.notificaciones IS 'Notificaciones in-app para egresados';

CREATE INDEX idx_notificaciones_egresado ON public.notificaciones(egresado_id);
CREATE INDEX idx_notificaciones_leida ON public.notificaciones(leida);
CREATE INDEX idx_notificaciones_tipo ON public.notificaciones(tipo);

-- ============================================
-- 2.11 TABLA: configuracion_sistema (PRIORIDAD MEDIA)
-- Configuración dinámica del sistema
-- ============================================
CREATE TABLE IF NOT EXISTS public.configuracion_sistema (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clave VARCHAR(100) NOT NULL UNIQUE,
    valor TEXT,
    tipo VARCHAR(50), -- 'texto', 'numero', 'boolean', 'json'
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.configuracion_sistema IS 'Configuración dinámica del sistema sin cambiar código';

CREATE INDEX idx_configuracion_clave ON public.configuracion_sistema(clave);

-- ============================================
-- 2.12 TABLA: historial_respuestas_autoevaluacion (PRIORIDAD BAJA)
-- Versionado de respuestas de autoevaluación
-- ============================================
CREATE TABLE IF NOT EXISTS public.historial_respuestas_autoevaluacion (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    respuesta_id UUID NOT NULL REFERENCES public.respuestas_autoevaluacion(id) ON DELETE CASCADE,
    egresado_id UUID NOT NULL REFERENCES public.egresados(id) ON DELETE CASCADE,
    pregunta_id UUID NOT NULL REFERENCES public.preguntas_autoevaluacion(id) ON DELETE CASCADE,
    respuesta_anterior_texto TEXT,
    respuesta_anterior_numerica INTEGER,
    respuesta_anterior_json JSONB,
    modificado_en TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.historial_respuestas_autoevaluacion IS 'Historial de cambios en respuestas de autoevaluación';

CREATE INDEX idx_historial_respuesta ON public.historial_respuestas_autoevaluacion(respuesta_id);
CREATE INDEX idx_historial_egresado ON public.historial_respuestas_autoevaluacion(egresado_id);

-- ============================================
-- 3. TRIGGERS PARA UPDATED_AT
-- ============================================

-- Función genérica para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER update_carreras_updated_at BEFORE UPDATE ON public.carreras
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_egresados_updated_at BEFORE UPDATE ON public.egresados
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_administradores_updated_at BEFORE UPDATE ON public.administradores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documentos_updated_at BEFORE UPDATE ON public.documentos_egresado
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preguntas_updated_at BEFORE UPDATE ON public.preguntas_autoevaluacion
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_respuestas_updated_at BEFORE UPDATE ON public.respuestas_autoevaluacion
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_modulos_updated_at BEFORE UPDATE ON public.modulos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_configuracion_updated_at BEFORE UPDATE ON public.configuracion_sistema
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 3.1 TRIGGER: Validación de correo institucional (PRIORIDAD ALTA)
-- ============================================
CREATE OR REPLACE FUNCTION validar_correo_institucional()
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

COMMENT ON FUNCTION validar_correo_institucional IS 'Valida que el correo sea institucional @campusucc.edu.co';

-- ============================================
-- 3.2 TRIGGER: Guardar historial de respuestas (PRIORIDAD BAJA)
-- ============================================
CREATE OR REPLACE FUNCTION guardar_historial_respuesta()
RETURNS TRIGGER AS $$
BEGIN
  -- Solo guardar si cambió la respuesta
  IF (OLD.respuesta_texto IS DISTINCT FROM NEW.respuesta_texto) OR
     (OLD.respuesta_numerica IS DISTINCT FROM NEW.respuesta_numerica) OR
     (OLD.respuesta_json IS DISTINCT FROM NEW.respuesta_json) THEN
    
    INSERT INTO public.historial_respuestas_autoevaluacion (
      respuesta_id,
      egresado_id,
      pregunta_id,
      respuesta_anterior_texto,
      respuesta_anterior_numerica,
      respuesta_anterior_json
    ) VALUES (
      OLD.id,
      OLD.egresado_id,
      OLD.pregunta_id,
      OLD.respuesta_texto,
      OLD.respuesta_numerica,
      OLD.respuesta_json
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER guardar_historial_antes_actualizar
  BEFORE UPDATE ON public.respuestas_autoevaluacion
  FOR EACH ROW
  EXECUTE FUNCTION guardar_historial_respuesta();

COMMENT ON FUNCTION guardar_historial_respuesta IS 'Guarda el historial de cambios en respuestas de autoevaluación';

-- ============================================
-- 4. VISTAS ÚTILES
-- ============================================

-- Vista con información completa de egresados (actualizada con nuevos campos)
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
    e.estado_laboral,
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
WHERE e.deleted_at IS NULL;

COMMENT ON VIEW public.v_egresados_completo IS 'Vista con información completa de egresados activos (sin eliminados)';

-- Vista de egresados activos (sin soft delete)
CREATE OR REPLACE VIEW public.v_egresados_activos AS
SELECT * FROM public.egresados WHERE deleted_at IS NULL;

COMMENT ON VIEW public.v_egresados_activos IS 'Solo egresados activos (excluye eliminados)';

-- Vista de estadísticas de autoevaluación
CREATE OR REPLACE VIEW public.v_estadisticas_autoevaluacion AS
SELECT 
    p.id AS pregunta_id,
    p.texto AS pregunta,
    p.categoria,
    COUNT(r.id) AS total_respuestas,
    AVG(r.respuesta_numerica) AS promedio_respuesta,
    MIN(r.respuesta_numerica) AS minimo,
    MAX(r.respuesta_numerica) AS maximo,
    STDDEV(r.respuesta_numerica) AS desviacion_estandar
FROM public.preguntas_autoevaluacion p
LEFT JOIN public.respuestas_autoevaluacion r ON p.id = r.pregunta_id
WHERE p.tipo = 'likert' AND p.activa = true
GROUP BY p.id, p.texto, p.categoria;

COMMENT ON VIEW public.v_estadisticas_autoevaluacion IS 'Estadísticas agregadas de respuestas de autoevaluación';

-- Vista de estadísticas laborales (PRIORIDAD MEDIA)
CREATE OR REPLACE VIEW public.v_estadisticas_laborales AS
SELECT 
    estado_laboral,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM egresados WHERE deleted_at IS NULL AND estado_laboral IS NOT NULL), 2) as porcentaje
FROM public.egresados
WHERE deleted_at IS NULL AND estado_laboral IS NOT NULL
GROUP BY estado_laboral
ORDER BY total DESC;

COMMENT ON VIEW public.v_estadisticas_laborales IS 'Estadísticas de empleabilidad de egresados';

-- Vista materializada para dashboard (PRIORIDAD BAJA)
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_estadisticas_dashboard AS
SELECT 
    COUNT(*) as total_egresados,
    COUNT(*) FILTER (WHERE habilitado = true) as habilitados,
    COUNT(*) FILTER (WHERE proceso_grado_completo = true) as proceso_completo,
    COUNT(*) FILTER (WHERE autoevaluacion_completada = true) as autoevaluacion_completa,
    COUNT(DISTINCT carrera_id) as total_carreras_activas,
    COUNT(*) FILTER (WHERE estado_laboral = 'empleado') as empleados,
    COUNT(*) FILTER (WHERE estado_laboral = 'desempleado') as desempleados,
    COUNT(*) FILTER (WHERE estado_laboral = 'emprendedor') as emprendedores,
    AVG(CASE WHEN autoevaluacion_completada THEN 
        (SELECT AVG(respuesta_numerica) FROM respuestas_autoevaluacion WHERE egresado_id = egresados.id)
    END) as promedio_autoevaluacion_general,
    NOW() as ultima_actualizacion
FROM public.egresados
WHERE deleted_at IS NULL;

COMMENT ON MATERIALIZED VIEW public.mv_estadisticas_dashboard IS 'Estadísticas pre-calculadas para dashboard administrativo. Refrescar periódicamente';

-- Índice para la vista materializada
CREATE UNIQUE INDEX idx_mv_dashboard_refresh ON public.mv_estadisticas_dashboard (ultima_actualizacion);

-- ============================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.egresados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documentos_egresado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respuestas_autoevaluacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.administradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cargas_excel ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5.1 POLÍTICAS RLS PARA EGRESADOS
-- ============================================

-- Los egresados pueden ver solo su propia información
CREATE POLICY "Egresados pueden ver su propia información"
    ON public.egresados FOR SELECT
    USING (auth.uid()::text = uid AND deleted_at IS NULL);

-- Los egresados pueden actualizar solo su propia información
CREATE POLICY "Egresados pueden actualizar su información"
    ON public.egresados FOR UPDATE
    USING (auth.uid()::text = uid AND deleted_at IS NULL);

-- Los egresados pueden insertar su propio registro (después del login)
CREATE POLICY "Egresados pueden crear su registro"
    ON public.egresados FOR INSERT
    WITH CHECK (auth.uid()::text = uid);

-- ============================================
-- 5.2 POLÍTICAS RLS PARA DOCUMENTOS
-- ============================================

-- Los egresados pueden ver solo sus propios documentos
CREATE POLICY "Egresados pueden ver sus documentos"
    ON public.documentos_egresado FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = documentos_egresado.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        ) AND documentos_egresado.deleted_at IS NULL
    );

-- Los egresados pueden insertar sus propios documentos
CREATE POLICY "Egresados pueden subir documentos"
    ON public.documentos_egresado FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = documentos_egresado.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

-- ============================================
-- 5.3 POLÍTICAS RLS PARA RESPUESTAS AUTOEVALUACIÓN
-- ============================================

-- Los egresados pueden ver solo sus propias respuestas
CREATE POLICY "Egresados pueden ver sus respuestas"
    ON public.respuestas_autoevaluacion FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = respuestas_autoevaluacion.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

-- Los egresados pueden insertar/actualizar sus propias respuestas
CREATE POLICY "Egresados pueden crear respuestas"
    ON public.respuestas_autoevaluacion FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = respuestas_autoevaluacion.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

CREATE POLICY "Egresados pueden actualizar respuestas"
    ON public.respuestas_autoevaluacion FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = respuestas_autoevaluacion.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

-- ============================================
-- 5.4 POLÍTICAS RLS PARA NOTIFICACIONES (PRIORIDAD ALTA)
-- ============================================

-- Los egresados pueden ver solo sus propias notificaciones
CREATE POLICY "Egresados pueden ver sus notificaciones"
    ON public.notificaciones FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = notificaciones.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

-- Los egresados pueden marcar como leídas sus notificaciones
CREATE POLICY "Egresados pueden actualizar sus notificaciones"
    ON public.notificaciones FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.egresados 
            WHERE id = notificaciones.egresado_id 
            AND uid = auth.uid()::text
            AND deleted_at IS NULL
        )
    );

-- ============================================
-- 5.5 POLÍTICAS PARA ADMINISTRADORES
-- ============================================
-- NOTA: Los administradores NO usan Supabase Auth, por lo que el backend
-- debe usar el service_role_key para acceder a todos los datos sin restricciones RLS

-- ============================================
-- 6. FUNCIONES ÚTILES
-- ============================================

-- Función para verificar si un egresado completó el proceso
CREATE OR REPLACE FUNCTION public.verificar_proceso_completo(p_egresado_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_documentos_requeridos INTEGER := 3; -- momento_ole, datos_egresados, bolsa_empleo
    v_documentos_subidos INTEGER;
BEGIN
    SELECT COUNT(DISTINCT tipo_documento)
    INTO v_documentos_subidos
    FROM public.documentos_egresado
    WHERE egresado_id = p_egresado_id
    AND tipo_documento IN ('momento_ole', 'datos_egresados', 'bolsa_empleo');
    
    RETURN v_documentos_subidos >= v_documentos_requeridos;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.verificar_proceso_completo IS 'Verifica si un egresado subió todos los documentos requeridos';

-- Función para obtener estadísticas generales
CREATE OR REPLACE FUNCTION public.obtener_estadisticas_generales()
RETURNS TABLE (
    total_egresados BIGINT,
    egresados_habilitados BIGINT,
    proceso_completo BIGINT,
    autoevaluacion_completada BIGINT,
    pendientes_validacion BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) AS total_egresados,
        COUNT(*) FILTER (WHERE habilitado = true) AS egresados_habilitados,
        COUNT(*) FILTER (WHERE proceso_grado_completo = true) AS proceso_completo,
        COUNT(*) FILTER (WHERE autoevaluacion_completada = true) AS autoevaluacion_completada,
        COUNT(*) FILTER (WHERE habilitado = false) AS pendientes_validacion
    FROM public.egresados;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.obtener_estadisticas_generales IS 'Obtiene estadísticas generales del sistema';

-- ============================================
-- 7. DATOS INICIALES
-- ============================================

-- Insertar carreras de ejemplo
INSERT INTO public.carreras (nombre, codigo, activa) VALUES
    ('Ingeniería de Sistemas', 'ING-SIS', true),
    ('Administración de Empresas', 'ADM-EMP', true),
    ('Contaduría Pública', 'CON-PUB', true),
    ('Derecho', 'DER', true),
    ('Psicología', 'PSI', true),
    ('Ingeniería Industrial', 'ING-IND', true),
    ('Comunicación Social', 'COM-SOC', true),
    ('Arquitectura', 'ARQ', true)
ON CONFLICT (nombre) DO NOTHING;

-- Insertar los 9 módulos (solo PreAlumni activo)
INSERT INTO public.modulos (nombre, descripcion, icono, orden, activo) VALUES
    ('PreAlumni', 'Proceso de grado y autoevaluación de competencias', 'school', 1, true),
    ('Red de Egresados', 'Conexión entre egresados del campus', 'people', 2, false),
    ('Bolsa de Empleo', 'Ofertas laborales y oportunidades', 'work', 3, false),
    ('Eventos Alumni', 'Eventos y actividades para egresados', 'event', 4, false),
    ('Mentoría', 'Programa de mentoría entre egresados', 'support', 5, false),
    ('Educación Continua', 'Cursos y capacitaciones', 'book', 6, false),
    ('Emprendimiento', 'Apoyo a emprendedores egresados', 'lightbulb', 7, false),
    ('Beneficios', 'Descuentos y beneficios exclusivos', 'card_giftcard', 8, false),
    ('Comunidad', 'Foros y grupos de interés', 'forum', 9, false)
ON CONFLICT (nombre) DO NOTHING;

-- Insertar preguntas de autoevaluación de ejemplo
INSERT INTO public.preguntas_autoevaluacion (texto, tipo, orden, categoria, activa) VALUES
    ('¿Cómo calificarías tu capacidad de trabajo en equipo?', 'likert', 1, 'competencias', true),
    ('¿Qué tan competente te sientes en la resolución de problemas complejos?', 'likert', 2, 'competencias', true),
    ('¿Cómo evalúas tu capacidad de comunicación efectiva?', 'likert', 3, 'competencias', true),
    ('¿Qué tan preparado te sientes para el mercado laboral?', 'likert', 4, 'empleabilidad', true),
    ('¿Cómo calificarías tu capacidad de adaptación al cambio?', 'likert', 5, 'competencias', true),
    ('¿Qué tan desarrolladas están tus habilidades de liderazgo?', 'likert', 6, 'competencias', true),
    ('¿Cómo evalúas tu pensamiento crítico y analítico?', 'likert', 7, 'competencias', true),
    ('¿Qué tan competente te sientes en el uso de tecnologías digitales?', 'likert', 8, 'competencias', true),
    ('¿Cómo calificarías tu capacidad de aprendizaje autónomo?', 'likert', 9, 'competencias', true),
    ('¿Qué tan desarrollada está tu ética profesional?', 'likert', 10, 'competencias', true)
ON CONFLICT DO NOTHING;

-- Crear un administrador inicial
-- Email: admin@campusucc.edu.co
-- Password: Admin123!
-- IMPORTANTE: Cambiar este password después del primer login
INSERT INTO public.administradores (correo, nombre, apellido, password_hash, rol, activo) VALUES
    ('admin@campusucc.edu.co', 'Administrador', 'Sistema', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'superadmin', true)
ON CONFLICT (correo) DO NOTHING;

-- ============================================
-- 7.1 CONFIGURACIÓN INICIAL DEL SISTEMA (PRIORIDAD MEDIA)
-- ============================================
INSERT INTO public.configuracion_sistema (clave, valor, tipo, descripcion) VALUES
    ('max_tamano_archivo_mb', '10', 'numero', 'Tamaño máximo de archivos en MB'),
    ('correo_soporte', 'soporte@campusucc.edu.co', 'texto', 'Email de soporte técnico'),
    ('mensaje_bienvenida', 'Bienvenido al Sistema Alumni UCC', 'texto', 'Mensaje de bienvenida en la app'),
    ('autoevaluacion_editable', 'false', 'boolean', 'Permitir editar respuestas de autoevaluación'),
    ('notificaciones_habilitadas', 'true', 'boolean', 'Sistema de notificaciones activo'),
    ('dominio_correo_institucional', '@campusucc.edu.co', 'texto', 'Dominio del correo institucional'),
    ('dias_vigencia_magic_link', '7', 'numero', 'Días de vigencia del magic link'),
    ('max_intentos_login', '5', 'numero', 'Máximo de intentos de login fallidos')
ON CONFLICT (clave) DO NOTHING;

-- ============================================
-- 8. CONFIGURACIÓN DE STORAGE (BUCKETS)
-- ============================================
-- NOTA: Los buckets se deben crear desde la interfaz de Supabase o mediante la API
-- Este es el esquema recomendado:

-- Bucket: egresados-documentos
-- - Público: NO
-- - Tamaño máximo archivo: 10MB
-- - Tipos permitidos: application/pdf, image/png, image/jpeg
-- - Estructura de carpetas: /egresados/{uid}/

-- Políticas de Storage recomendadas (crear desde Supabase Dashboard):
-- 1. Los egresados pueden subir archivos a su propia carpeta
-- 2. Los egresados pueden leer archivos de su propia carpeta
-- 3. El backend (service_role) tiene acceso completo

-- ============================================
-- 9. ÍNDICES ADICIONALES PARA PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_egresados_proceso_completo 
    ON public.egresados(proceso_grado_completo) 
    WHERE proceso_grado_completo = true;

CREATE INDEX IF NOT EXISTS idx_egresados_autoevaluacion 
    ON public.egresados(autoevaluacion_completada) 
    WHERE autoevaluacion_completada = true;

CREATE INDEX IF NOT EXISTS idx_documentos_egresado_tipo 
    ON public.documentos_egresado(egresado_id, tipo_documento);

-- ============================================
-- 10. GRANTS Y PERMISOS
-- ============================================

-- Dar permisos a usuarios autenticados (egresados)
GRANT SELECT, INSERT, UPDATE ON public.egresados TO authenticated;
GRANT SELECT, INSERT ON public.documentos_egresado TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.respuestas_autoevaluacion TO authenticated;
GRANT SELECT ON public.preguntas_autoevaluacion TO authenticated;
GRANT SELECT ON public.carreras TO authenticated;
GRANT SELECT ON public.modulos TO authenticated;
GRANT SELECT ON public.v_egresados_completo TO authenticated;
GRANT SELECT ON public.v_egresados_activos TO authenticated;
GRANT SELECT ON public.v_estadisticas_autoevaluacion TO authenticated;
GRANT SELECT, UPDATE ON public.notificaciones TO authenticated;
GRANT SELECT ON public.configuracion_sistema TO authenticated;

-- Dar permisos a usuarios anónimos (para registro inicial)
GRANT SELECT ON public.carreras TO anon;
GRANT SELECT ON public.modulos TO anon;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Verificar que todo se creó correctamente
SELECT 'Base de datos Alumni creada exitosamente' AS mensaje;

-- Mostrar resumen de tablas creadas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
    'carreras', 'egresados', 'administradores', 'documentos_egresado',
    'preguntas_autoevaluacion', 'respuestas_autoevaluacion', 
    'cargas_excel', 'modulos', 'logs_sistema', 'notificaciones',
    'configuracion_sistema', 'historial_respuestas_autoevaluacion'
)
ORDER BY tablename;
