-- ============================================
-- ACTUALIZAR ADMINISTRADOR CON HASH CORRECTO
-- ============================================
-- Este script actualiza el administrador existente con el hash bcrypt correcto
-- Email: admin@campusucc.edu.co
-- Password: Admin123!

-- Eliminar el administrador anterior (si existe)
DELETE FROM public.administradores WHERE correo = 'admin@campusucc.edu.co';

-- Crear el administrador con el hash correcto
INSERT INTO public.administradores (correo, nombre, apellido, password_hash, rol, activo) VALUES
    ('admin@campusucc.edu.co', 'Administrador', 'Sistema', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'superadmin', true);

-- Verificar que se creó correctamente
SELECT id, correo, nombre, apellido, rol, activo, created_at 
FROM public.administradores 
WHERE correo = 'admin@campusucc.edu.co';
