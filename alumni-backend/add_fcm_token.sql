-- Agregar columna para almacenar el token de Firebase Cloud Messaging
ALTER TABLE public.egresados 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Agregar comentario descriptivo
COMMENT ON COLUMN public.egresados.fcm_token IS 'Token de Firebase Cloud Messaging para notificaciones push';

-- Crear índice para búsquedas rápidas por token
CREATE INDEX IF NOT EXISTS idx_egresados_fcm_token 
ON public.egresados(fcm_token) 
WHERE fcm_token IS NOT NULL;
