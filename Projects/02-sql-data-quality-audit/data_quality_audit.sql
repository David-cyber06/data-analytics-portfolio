-- CREAR TABLAS PARA AUDITORÍA DE YELP
"""
-- Tabla business
CREATE TABLE IF NOT EXISTS business (
    business_id TEXT PRIMARY KEY,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INTEGER,
    is_open INTEGER,
    attributes JSON,
    categories TEXT,
    hours JSON
);

-- Tabla review
CREATE TABLE IF NOT EXISTS review (
    review_id TEXT PRIMARY KEY,
    user_id TEXT,
    business_id TEXT,
    stars INTEGER,
    useful INTEGER,
    funny INTEGER,
    cool INTEGER,
    text TEXT,
    date DATE
);

-- Tabla user
CREATE TABLE IF NOT EXISTS yelp_user (
    user_id TEXT PRIMARY KEY,
    name TEXT,
    review_count INTEGER,
    yelping_since DATE,
    friends TEXT,
    useful INTEGER,
    funny INTEGER,
    cool INTEGER,
    fans INTEGER,
    elite TEXT,
    average_stars FLOAT
);

-- Tabla checkin
CREATE TABLE IF NOT EXISTS checkin (
    business_id TEXT,
    date TEXT,
    PRIMARY KEY (business_id, date)
);

-- Tabla de resultados de auditoría
CREATE TABLE IF NOT EXISTS audit_results (
    id SERIAL PRIMARY KEY,
    audit_date DATE DEFAULT CURRENT_DATE,
    table_name VARCHAR(50),
    issue_type VARCHAR(50),
    issue_count INTEGER,
    description TEXT,
    severity VARCHAR(20)
);

-- Verificar tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM audit_results;
SELECT * FROM business;
SELECT * FROM checkin;
SELECT * FROM review;
SELECT * FROM yelp_user;
SELECT COUNT(*) FROM business;
SELECT COUNT(*) FROM review;
SELECT COUNT(*) FROM yelp_user;

-- AUDITORÍA DE CALIDAD DE DATOS - YELP DATASET

-- 1. VERIFICAR ESTRUCTURA DE TABLAS

-- Ver columnas de cada tabla
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Ver conteo de registros
SELECT 
    'business' AS tabla, COUNT(*) AS total_registros FROM business
UNION ALL
SELECT 
    'review', COUNT(*) FROM review
UNION ALL
SELECT 
    'yelp_user', COUNT(*) FROM yelp_user;

-- 2. DUPLICADOS

-- 2.1 Duplicados en business
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'duplicates',
    COUNT(*) - COUNT(DISTINCT business_id),
    'business_id duplicados en tabla business',
    'HIGH'
FROM business;

-- 2.2 Duplicados en review
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'duplicates',
    COUNT(*) - COUNT(DISTINCT review_id),
    'review_id duplicados en tabla review',
    'HIGH'
FROM review;

-- 2.3 Duplicados en user
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'duplicates',
    COUNT(*) - COUNT(DISTINCT user_id),
    'user_id duplicados en tabla yelp_user',
    'HIGH'
FROM yelp_user;

-- 3. VALORES NULOS

-- 3.1 Business - Nulos en columnas clave
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'nulls',
    COUNT(*) FILTER (WHERE name IS NULL OR TRIM(name) = ''),
    'business_name NULL o vacío',
    'MEDIUM'
FROM business;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'nulls',
    COUNT(*) FILTER (WHERE city IS NULL OR TRIM(city) = ''),
    'city NULL o vacío',
    'MEDIUM'
FROM business;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'nulls',
    COUNT(*) FILTER (WHERE postal_code IS NULL OR TRIM(postal_code) = ''),
    'postal_code NULL o vacío',
    'LOW'
FROM business;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'nulls',
    COUNT(*) FILTER (WHERE address IS NULL OR TRIM(address) = ''),
    'address NULL o vacío',
    'LOW'
FROM business;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'nulls',
    COUNT(*) FILTER (WHERE categories IS NULL OR TRIM(categories) = ''),
    'categories NULL o vacío',
    'MEDIUM'
FROM business;

-- 3.2 Review - Nulos en columnas clave
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'nulls',
    COUNT(*) FILTER (WHERE text IS NULL OR TRIM(text) = ''),
    'review_text NULL o vacío',
    'HIGH'
FROM review;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'nulls',
    COUNT(*) FILTER (WHERE stars IS NULL),
    'stars NULL en review',
    'HIGH'
FROM review;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'nulls',
    COUNT(*) FILTER (WHERE user_id IS NULL OR TRIM(user_id) = ''),
    'user_id NULL o vacío en review',
    'HIGH'
FROM review;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'nulls',
    COUNT(*) FILTER (WHERE business_id IS NULL OR TRIM(business_id) = ''),
    'business_id NULL o vacío en review',
    'HIGH'
FROM review;

-- 3.3 User - Nulos en columnas clave
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'nulls',
    COUNT(*) FILTER (WHERE name IS NULL OR TRIM(name) = ''),
    'user_name NULL o vacío',
    'MEDIUM'
FROM yelp_user;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'nulls',
    COUNT(*) FILTER (WHERE review_count IS NULL),
    'review_count NULL',
    'HIGH'
FROM yelp_user;

INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'nulls',
    COUNT(*) FILTER (WHERE average_stars IS NULL),
    'average_stars NULL',
    'MEDIUM'
FROM yelp_user;

-- 4. VALORES INVÁLIDOS

-- 4.1 Review - Stars fuera de rango
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'invalid_values',
    COUNT(*) FILTER (WHERE stars < 1 OR stars > 5),
    'stars fuera de rango (1-5) en review',
    'HIGH'
FROM review;

-- 4.2 Business - Stars fuera de rango
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'invalid_values',
    COUNT(*) FILTER (WHERE stars < 1 OR stars > 5),
    'stars fuera de rango (1-5) en business',
    'HIGH'
FROM business;

-- 4.3 Business - review_count negativo
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'invalid_values',
    COUNT(*) FILTER (WHERE review_count < 0),
    'review_count negativo en business',
    'HIGH'
FROM business;

-- 4.4 Business - is_open inválido
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'invalid_values',
    COUNT(*) FILTER (WHERE is_open NOT IN (0, 1) OR is_open IS NULL),
    'is_open inválido (0 o 1) en business',
    'HIGH'
FROM business;

-- 4.5 User - fans negativo
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'invalid_values',
    COUNT(*) FILTER (WHERE fans < 0),
    'fans negativo en yelp_user',
    'HIGH'
FROM yelp_user;

-- 4.6 User - average_stars fuera de rango
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'invalid_values',
    COUNT(*) FILTER (WHERE average_stars < 1 OR average_stars > 5),
    'average_stars fuera de rango (1-5)',
    'MEDIUM'
FROM yelp_user;

-- 5. REGISTROS HUÉRFANOS (INCONSISTENCIAS)

-- 5.1 Reviews sin business asociado
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'orphan_records',
    COUNT(*),
    'reviews sin business asociado (business_id no existe)',
    'HIGH'
FROM review r
LEFT JOIN business b ON r.business_id = b.business_id
WHERE b.business_id IS NULL;

-- 5.2 Reviews sin user asociado
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'orphan_records',
    COUNT(*),
    'reviews sin user asociado (user_id no existe)',
    'HIGH'
FROM review r
LEFT JOIN yelp_user u ON r.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 6. INCONSISTENCIAS DE DATOS

-- 6.1 Business: stars > 0 pero sin reviews
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'inconsistent_data',
    COUNT(*),
    'business con stars > 0 pero review_count = 0',
    'MEDIUM'
FROM business
WHERE stars > 0 AND review_count = 0;

-- 6.2 User: review_count no coincide con reviews reales
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'inconsistent_data',
    COUNT(*),
    'review_count no coincide con número real de reviews',
    'MEDIUM'
FROM (
    SELECT 
        u.user_id,
        u.review_count,
        COUNT(r.review_id) AS actual_count
    FROM yelp_user u
    LEFT JOIN review r ON u.user_id = r.user_id
    GROUP BY u.user_id, u.review_count
    HAVING u.review_count != COUNT(r.review_id)
) AS inconsistent;

-- 6.3 Business: latitude o longitude faltante
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'missing_data',
    COUNT(*) FILTER (WHERE latitude IS NULL OR longitude IS NULL),
    'latitud o longitud faltante en business',
    'LOW'
FROM business;

-- 7. DATOS FALTANTES

-- 7.1 Reviews sin texto útil
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'review',
    'missing_data',
    COUNT(*) FILTER (WHERE LENGTH(TRIM(text)) < 10),
    'reviews con texto muy corto (< 10 caracteres)',
    'LOW'
FROM review;

-- 7.2 Business sin categorías
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'business',
    'missing_data',
    COUNT(*) FILTER (WHERE categories IS NULL OR TRIM(categories) = ''),
    'negocios sin categorías',
    'MEDIUM'
FROM business;

-- 7.3 User sin amigos
INSERT INTO audit_results (audit_date, table_name, issue_type, issue_count, description, severity)
SELECT 
    CURRENT_DATE,
    'yelp_user',
    'missing_data',
    COUNT(*) FILTER (WHERE friends IS NULL OR TRIM(friends) = ''),
    'usuarios sin amigos en el sistema',
    'LOW'
FROM yelp_user;

-- 8. RESUMEN DE RESULTADOS

-- 8.1 Ver todos los resultados
SELECT 
    id,
    audit_date,
    table_name,
    issue_type,
    issue_count,
    description,
    severity
FROM audit_results
ORDER BY severity DESC, issue_count DESC;

-- 8.2 KPIs principales
SELECT 
    COUNT(DISTINCT table_name) AS tablas_auditadas,
    SUM(issue_count) AS total_incidencias,
    COUNT(DISTINCT issue_type) AS tipos_problemas,
    SUM(CASE WHEN severity = 'HIGH' THEN issue_count ELSE 0 END) AS criticos,
    SUM(CASE WHEN severity = 'MEDIUM' THEN issue_count ELSE 0 END) AS medios,
    SUM(CASE WHEN severity = 'LOW' THEN issue_count ELSE 0 END) AS bajos
FROM audit_results;

-- 8.3 Resumen por tabla
SELECT 
    table_name,
    COUNT(*) AS total_issues,
    SUM(issue_count) AS total_incidencias,
    SUM(CASE WHEN severity = 'HIGH' THEN issue_count ELSE 0 END) AS criticos,
    SUM(CASE WHEN severity = 'MEDIUM' THEN issue_count ELSE 0 END) AS medios,
    SUM(CASE WHEN severity = 'LOW' THEN issue_count ELSE 0 END) AS bajos
FROM audit_results
GROUP BY table_name
ORDER BY total_incidencias DESC;