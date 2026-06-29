# CARGAR DATOS DE YELP A POSTGRESQL

import pandas as pd
import json
import psycopg2
import os
import kagglehub

# 1. Descargar dataset
path = kagglehub.dataset_download("yelp-dataset/yelp-dataset")

# 2. Conectar a PostgreSQL
conn = psycopg2.connect(
    host="localhost",
    database="yelp_audit",
    user="postgres",
    password="#####"
)
cursor = conn.cursor()

# 3. Función para cargar JSON
def load_json_to_postgres(json_file, table_name, columns, limit=50000):
    print(f"Cargando {table_name}...")
    data = []
    with open(json_file, "r", encoding="utf-8") as f:
        for i, line in enumerate(f):
            if i >= limit:
                break
            try:
                row = json.loads(line)
                filtered_row = {}
                for col in columns:
                    value = row.get(col)
                    if isinstance(value, (dict, list)):
                        value = json.dumps(value)
                    filtered_row[col] = value
                data.append(filtered_row)
            except Exception as e:
                print(f"Error leyendo fila {i}: {e}")

    df = pd.DataFrame(data)
    placeholders = ", ".join(["%s"] * len(columns))
    columns_str = ", ".join(columns)
    sql = f"""
        INSERT INTO {table_name}
        ({columns_str})
        VALUES ({placeholders})
    """
    inserted = 0
    for _, row in df.iterrows():
        try:
            values = []
            for col in columns:
                value = row[col]
                if pd.isna(value):
                    value = None
                values.append(value)
            cursor.execute(sql, tuple(values))
            inserted += 1
        except Exception as e:
            print(f"Error insertando registro: {e}"
            conn.rollback()
    conn.commit()
    print(f"{inserted} registros cargados en '{table_name}'")

# BUSINESS
business_columns = [
    'business_id',
    'name',
    'address',
    'city',
    'state',
    'postal_code',
    'latitude',
    'longitude',
    'stars',
    'review_count',
    'is_open',
    'attributes',
    'categories',
    'hours'
]

load_json_to_postgres(
    os.path.join(path, 'yelp_academic_dataset_business.json'),
    'business',
    business_columns,
    50000
)

# REVIEW

review_columns = [
    'review_id',
    'user_id',
    'business_id',
    'stars',
    'useful',
    'funny',
    'cool',
    'text',
    'date'
]

load_json_to_postgres(
    os.path.join(path, 'yelp_academic_dataset_review.json'),
    'review',
    review_columns,
    100000
)

# USER

user_columns = [
    'user_id',
    'name',
    'review_count',
    'yelping_since',
    'friends',
    'useful',
    'funny',
    'cool',
    'fans',
    'elite',
    'average_stars'
]

load_json_to_postgres(
    os.path.join(path, 'yelp_academic_dataset_user.json'),
    'yelp_user',
    user_columns,
    50000
)

# VERIFICAR

print("\nTABLAS DISPONIBLES:")

tables = pd.read_sql_query("""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    ORDER BY table_name
""", conn)

print(tables)

cursor.close()
conn.close()