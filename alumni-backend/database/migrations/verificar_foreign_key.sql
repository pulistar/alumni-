-- ============================================
-- VERIFICAR SI EXISTE LA FOREIGN KEY
-- ============================================
-- Ejecuta este script en Supabase SQL Editor

-- 1. Verificar si existe la foreign key constraint
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name = 'egresados' 
  AND tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'estados_laborales';

-- Si el resultado está VACÍO, significa que NO EXISTE la foreign key
-- Si aparece una fila con 'fk_egresados_estado_laboral', entonces SÍ EXISTE

-- 2. Si NO existe, créala con este comando:
-- (Descomenta las siguientes líneas si necesitas crearla)

/*
ALTER TABLE public.egresados
ADD CONSTRAINT fk_egresados_estado_laboral 
FOREIGN KEY (estado_laboral_id) 
REFERENCES public.estados_laborales(id)
ON DELETE SET NULL;

-- Crear índice
CREATE INDEX IF NOT EXISTS idx_egresados_estado_laboral_id 
ON public.egresados(estado_laboral_id);

-- Recargar schema de Supabase
NOTIFY pgrst, 'reload schema';
*/

-- 3. Verificar que la columna existe
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'egresados'
  AND column_name = 'estado_laboral_id';
