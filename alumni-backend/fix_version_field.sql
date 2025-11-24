-- ============================================
-- CORRECCIONES POST-REVISIÓN
-- ============================================
-- Este script corrige los issues encontrados en la revisión exhaustiva

-- ============================================
-- 1. Agregar campo 'version' a respuestas_autoevaluacion
-- ============================================
ALTER TABLE public.respuestas_autoevaluacion 
ADD COLUMN IF NOT EXISTS version INTEGER DEFAULT 1;

COMMENT ON COLUMN public.respuestas_autoevaluacion.version IS 'Versión de la respuesta, se incrementa en cada actualización';

-- ============================================
-- 2. Crear trigger para incrementar versión automáticamente
-- ============================================
CREATE OR REPLACE FUNCTION increment_respuesta_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger solo si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'increment_version_on_update'
    ) THEN
        CREATE TRIGGER increment_version_on_update
        BEFORE UPDATE ON public.respuestas_autoevaluacion
        FOR EACH ROW
        EXECUTE FUNCTION increment_respuesta_version();
    END IF;
END $$;

COMMENT ON TRIGGER increment_version_on_update ON public.respuestas_autoevaluacion IS 'Incrementa automáticamente la versión al actualizar una respuesta';
