-- ============================================
-- Agregar Foreign Key entre egresados y estados_laborales
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

-- 1. Verificar que la columna existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'egresados' 
        AND column_name = 'estado_laboral_id'
    ) THEN
        ALTER TABLE public.egresados 
        ADD COLUMN estado_laboral_id UUID;
        RAISE NOTICE 'Columna estado_laboral_id agregada';
    ELSE
        RAISE NOTICE 'Columna estado_laboral_id ya existe';
    END IF;
END $$;

-- 2. Eliminar constraint si existe (para evitar errores)
ALTER TABLE public.egresados 
DROP CONSTRAINT IF EXISTS fk_egresados_estado_laboral;

-- 3. Crear la foreign key constraint
ALTER TABLE public.egresados
ADD CONSTRAINT fk_egresados_estado_laboral 
FOREIGN KEY (estado_laboral_id) 
REFERENCES public.estados_laborales(id)
ON DELETE SET NULL;

-- 4. Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_egresados_estado_laboral_id 
ON public.egresados(estado_laboral_id);

-- 5. Verificación - Mostrar la constraint creada
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'egresados' 
  AND tc.constraint_type = 'FOREIGN KEY'
  AND tc.constraint_name = 'fk_egresados_estado_laboral';

-- 6. Probar el join
SELECT 
  e.id,
  e.nombre,
  e.apellido,
  e.estado_laboral_id,
  el.nombre as estado_laboral_nombre
FROM egresados e
LEFT JOIN estados_laborales el ON e.estado_laboral_id = el.id
LIMIT 5;

-- Mensaje de éxito
SELECT 'Foreign key creada exitosamente! Ahora Supabase puede hacer joins automáticos.' AS resultado;
