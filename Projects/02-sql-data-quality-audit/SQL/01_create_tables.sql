-- CREAR TABLAS PARA AUDITORÍA DE YELP
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
