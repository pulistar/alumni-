-- =====================================================
-- Configuración de Supabase Storage para Documentos
-- =====================================================
-- Este script configura el bucket y las políticas RLS
-- para la gestión de documentos de egresados.
--
-- IMPORTANTE: Ejecutar DESPUÉS de crear el bucket manualmente
-- en Supabase Dashboard → Storage → Create Bucket
-- Nombre: egresados-documentos
-- Public: NO
-- File size limit: 10MB
-- =====================================================

-- =====================================================
-- POLÍTICAS RLS PARA STORAGE
-- =====================================================

-- 1. Permitir a egresados subir archivos a su propia carpeta
CREATE POLICY "Egresados pueden subir a su carpeta"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'egresados-documentos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 2. Permitir a egresados leer archivos de su propia carpeta
CREATE POLICY "Egresados pueden leer su carpeta"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'egresados-documentos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 3. Permitir a egresados eliminar archivos de su propia carpeta
CREATE POLICY "Egresados pueden eliminar de su carpeta"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'egresados-documentos' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Verificar que las políticas se crearon correctamente
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'objects' 
  AND policyname LIKE '%Egresados%'
ORDER BY policyname;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- 
-- 1. El bucket debe crearse manualmente en Supabase Dashboard
-- 2. Configuración del bucket:
--    - Nombre: egresados-documentos
--    - Public: NO (privado)
--    - File size limit: 10MB
--    - Allowed MIME types: application/pdf, image/png, image/jpeg
--
-- 3. Estructura de carpetas:
--    /{uid}/{timestamp}-{filename}
--    Ejemplo: /4a30e9cf-f59f-4066-a829-5d9bc38f8aa0/1700000000-documento.pdf
--
-- 4. Las URLs firmadas expiran en 1 hora
--
-- =====================================================
