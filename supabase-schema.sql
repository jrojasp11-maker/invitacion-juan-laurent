-- ========================================
-- ESQUEMA SUPABASE: INVITACIÓN JUAN → LAURENT
-- ========================================
-- Ejecutar en Supabase Dashboard > SQL Editor
-- O via CLI: supabase db push --file supabase-schema.sql
-- ========================================

-- ----------------------------------------
-- 1. EXTENSIONES NECESARIAS
-- ----------------------------------------
-- uuid-ossp ya viene por defecto en Supabase para gen_random_uuid()
-- pgcrypto para criptografía si se necesita en el futuro
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------
-- 2. TABLA PRINCIPAL: respuestas_cita
-- ----------------------------------------
CREATE TABLE IF NOT EXISTS public.respuestas_cita (
    -- Identificador único
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Timestamp automático con zona horaria
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    
    -- Preferencia seleccionada (obligatoria)
    genero_pelicula TEXT NOT NULL,
    -- Sushi ya no se solicita en la app; se deja nullable por compatibilidad
    sushi_favorito TEXT,
    
    -- Estado de la respuesta
    estado TEXT DEFAULT 'Aceptado' NOT NULL
        CHECK (estado IN ('Aceptado', 'Pendiente', 'Rechazado')),
    
    -- Metadatos opcionales para analytics
    user_agent TEXT,
    ip_hash TEXT,          -- Hash de IP para privacidad (no IP directa)
    referrer TEXT
);

-- ----------------------------------------
-- 3. ÍNDICES PARA PERFORMANCE
-- ----------------------------------------
-- Índice por fecha (consultas temporales frecuentes)
CREATE INDEX IF NOT EXISTS idx_respuestas_created_at 
    ON public.respuestas_cita (created_at DESC);

-- Índice por estado (filtrar aceptados/pendientes)
CREATE INDEX IF NOT EXISTS idx_respuestas_estado 
    ON public.respuestas_cita (estado);

-- Índice compuesto para analytics
CREATE INDEX IF NOT EXISTS idx_respuestas_pelicula_sushi 
    ON public.respuestas_cita (genero_pelicula, sushi_favorito);

-- ----------------------------------------
-- 4. ROW LEVEL SECURITY (RLS)
-- ----------------------------------------
ALTER TABLE public.respuestas_cita ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------
-- 5. POLÍTICAS DE SEGURIDAD
-- ----------------------------------------

-- 5.1 INSERCIÓN PÚBLICA (anon key desde frontend)
-- Permite a cualquiera insertar su respuesta
CREATE POLICY "Permitir inserciones publicas" 
    ON public.respuestas_cita 
    FOR INSERT 
    TO anon 
    WITH CHECK (true);

-- 5.2 LECTURA AUTENTICADA (solo usuarios logueados en Supabase)
-- Para ver respuestas en dashboard/admin
CREATE POLICY "Lectura para usuarios autenticados" 
    ON public.respuestas_cita 
    FOR SELECT 
    TO authenticated 
    USING (true);

-- 5.3 LECTURA PARA SERVICE ROLE (backend/admin scripts)
-- Acceso total para scripts de administración
CREATE POLICY "Acceso total service role" 
    ON public.respuestas_cita 
    FOR ALL 
    TO service_role 
    USING (true) 
    WITH CHECK (true);

-- ----------------------------------------
-- 6. FUNCIONES Y TRIGGERS (OPCIONALES)
-- ----------------------------------------

-- 6.1 Función para hashear IP (privacidad)
CREATE OR REPLACE FUNCTION public.hash_ip(ip TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT encode(digest(ip || current_setting('app.ip_salt', true), 'sha256'), 'hex')
$$;

-- 6.2 Trigger para capturar metadatos automáticamente
CREATE OR REPLACE FUNCTION public.capture_request_metadata()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Capturar User-Agent si viene en headers (requiere configuración en Supabase)
    -- NEW.user_agent := current_setting('request.headers.user-agent', true);
    
    -- Hash de IP (requiere configuración de ip_salt en postgresql.conf)
    -- NEW.ip_hash := public.hash_ip(current_setting('request.ip', true));
    
    -- Referrer
    -- NEW.referrer := current_setting('request.headers.referer', true);
    
    RETURN NEW;
END;
$$;

-- Descomenta para activar (requiere configuración adicional en Supabase):
-- CREATE TRIGGER trigger_capture_metadata
--     BEFORE INSERT ON public.respuestas_cita
--     FOR EACH ROW
--     EXECUTE FUNCTION public.capture_request_metadata();

-- ----------------------------------------
-- 7. VISTAS PARA ANALYTICS (OPCIONALES)
-- ----------------------------------------

-- 7.1 Vista: Resumen por película
CREATE OR REPLACE VIEW public.v_peliculas_populares AS
SELECT 
    genero_pelicula,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as porcentaje
FROM public.respuestas_cita
WHERE estado = 'Aceptado'
GROUP BY genero_pelicula
ORDER BY total DESC;

-- 7.2 Vista: Resumen por sushi
CREATE OR REPLACE VIEW public.v_sushi_popular AS
SELECT 
    sushi_favorito,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as porcentaje
FROM public.respuestas_cita
WHERE estado = 'Aceptado'
GROUP BY sushi_favorito
ORDER BY total DESC;

-- 7.3 Vista: Respuestas diarias
CREATE OR REPLACE VIEW public.v_respuestas_diarias AS
SELECT 
    DATE(created_at AT TIME ZONE 'America/Argentina/Buenos_Aires') as fecha,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE estado = 'Aceptado') as aceptados
FROM public.respuestas_cita
GROUP BY 1
ORDER BY 1 DESC;

-- ----------------------------------------
-- 8. DATOS DE PRUEBA (OPCIONAL - DESARROLLO)
-- ----------------------------------------
-- Descomenta solo para testing local:
/*
INSERT INTO public.respuestas_cita (genero_pelicula, estado) VALUES
    ('Comedia', 'Aceptado'),
    ('Sci-Fi', 'Aceptado'),
    ('Terror', 'Aceptado'),
    ('Drama', 'Aceptado');
*/

-- ----------------------------------------
-- 9. CONSULTAS ÚTILES PARA DASHBOARD
-- ----------------------------------------

-- Total de respuestas
-- SELECT COUNT(*) FROM public.respuestas_cita WHERE estado = 'Aceptado';

-- Últimas 10 respuestas
-- SELECT genero_pelicula, sushi_favorito, created_at AT TIME ZONE 'America/Argentina/Buenos_Aires' as fecha_local
-- FROM public.respuestas_cita 
-- WHERE estado = 'Aceptado'
-- ORDER BY created_at DESC 
-- LIMIT 10;

-- Distribución combinada (película + sushi)
-- SELECT genero_pelicula, sushi_favorito, COUNT(*) as total
-- FROM public.respuestas_cita
-- WHERE estado = 'Aceptado'
-- GROUP BY genero_pelicula, sushi_favorito
-- ORDER BY total DESC;

-- ----------------------------------------
-- 10. LIMPIEZA Y MIGRACIONES
-- ----------------------------------------
-- MIGRACIÓN: ejecutar SOLO si la tabla YA existía antes (sushi_favorito era NOT NULL)
-- ALTER TABLE public.respuestas_cita ALTER COLUMN sushi_favorito DROP NOT NULL;

-- DROP TABLE IF EXISTS public.respuestas_cita CASCADE;
-- DROP VIEW IF EXISTS public.v_peliculas_populares, public.v_sushi_popular, public.v_respuestas_diarias;
-- DROP FUNCTION IF EXISTS public.hash_ip(TEXT), public.capture_request_metadata();

-- ----------------------------------------
-- FIN DEL ESQUEMA
-- ========================================