from bottle import Bottle, template, static_file, request, response, TEMPLATE_PATH
import psycopg2
from datetime import datetime

app = Bottle()
# Add template path
TEMPLATE_PATH.append('./views/')

# Datenbankverbindung herstellen
def get_db_connection():
    return psycopg2.connect(
        host="awsbase.cw6qjfqpxzus.us-east-1.rds.amazonaws.com",
        database="postgres",
        user="postgres",
        password="postgres",
        port="5432",
        sslmode="require",
        options="-c search_path=bonusql"
    )

@app.route('/')
@app.route('/medien')
def show_all_media():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        sql = """
        WITH creator_names AS (
            SELECT 
                m.medium_id,
                m.medientyp,
                string_agg(
                    CONCAT(p.vorname, ' ', p.nachname),
                    '; '
                    ORDER BY r.role_name, p.nachname, p.vorname
                ) as creator
            FROM medium m
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id 
                AND m.medientyp = mpr.medientyp
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            GROUP BY m.medium_id, m.medientyp
        )
        SELECT 
            m.medium_id,
            m.titel,
            m.medientyp,
            m.erscheinungsjahr,
            m.datentraeger,
            m.zustand,
            m.barcode,
            m.notizen,
            COALESCE(c.creator, '') as autoren
        FROM medium m
        LEFT JOIN creator_names c ON m.medium_id = c.medium_id AND m.medientyp = c.medientyp
        ORDER BY m.titel;
        """
        
        cur.execute(sql)
        
        medien = []
        for row in cur.fetchall():
            medium = {
                'medium_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'erscheinungsjahr': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'barcode': row[6],
                'notizen': row[7],
                'autoren': row[8] if row[8] else ''
            }
            medien.append(medium)
        
        cur.close()
        conn.close()
        
        return template('medien', title='Alle Medien', medien=medien)
    except Exception as e:
        return template('error', error=str(e))

@app.route('/medien/<typ>')
def show_media_by_type(typ):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        sql = """
        WITH creator_names AS (
            SELECT 
                m.medium_id,
                m.medientyp,
                string_agg(
                    CONCAT(p.vorname, ' ', p.nachname),
                    '; '
                    ORDER BY r.role_name, p.nachname, p.vorname
                ) as creator
            FROM medium m
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id 
                AND m.medientyp = mpr.medientyp
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            WHERE m.medientyp = %s
            GROUP BY m.medium_id, m.medientyp
        )
        SELECT 
            m.medium_id,
            m.titel,
            m.medientyp,
            m.erscheinungsjahr,
            m.datentraeger,
            m.zustand,
            m.barcode,
            m.notizen,
            COALESCE(c.creator, '') as autoren
        FROM medium m
        LEFT JOIN creator_names c ON m.medium_id = c.medium_id AND m.medientyp = c.medientyp
        WHERE m.medientyp = %s
        ORDER BY m.titel;
        """
        
        cur.execute(sql, (typ, typ))
        
        medien = []
        for row in cur.fetchall():
            medium = {
                'medium_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'erscheinungsjahr': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'barcode': row[6],
                'notizen': row[7],
                'autoren': row[8] if row[8] else ''
            }
            medien.append(medium)
        
        cur.close()
        conn.close()
        
        return template('medien', title=f'Medien vom Typ: {typ}', medien=medien)
    except Exception as e:
        return template('error', error=str(e))

@app.route('/static/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='./static')

@app.route('/search', method='POST')
def search():
    try:
        query = request.forms.get('query', '').strip()
        conn = get_db_connection()
        cur = conn.cursor()
        
        sql = """
        WITH creator_names AS (
            SELECT 
                m.medium_id,
                m.medientyp,
                string_agg(
                    CONCAT(p.vorname, ' ', p.nachname),
                    '; '
                    ORDER BY r.role_name, p.nachname, p.vorname
                ) as creator
            FROM medium m
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id 
                AND m.medientyp = mpr.medientyp
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            GROUP BY m.medium_id, m.medientyp
        )
        SELECT 
            m.medium_id,
            m.titel,
            m.medientyp,
            m.erscheinungsjahr,
            m.datentraeger,
            m.zustand,
            m.barcode,
            m.notizen,
            COALESCE(c.creator, '') as autoren
        FROM medium m
        LEFT JOIN creator_names c ON m.medium_id = c.medium_id AND m.medientyp = c.medientyp
        WHERE 
            LOWER(m.titel) LIKE LOWER(%s)
            OR LOWER(m.barcode) LIKE LOWER(%s)
            OR EXISTS (
                SELECT 1
                FROM medium_person_role mpr
                JOIN person p ON mpr.person_id = p.person_id
                WHERE mpr.medium_id = m.medium_id 
                    AND mpr.medientyp = m.medientyp
                    AND (
                        LOWER(p.vorname) LIKE LOWER(%s)
                        OR LOWER(p.nachname) LIKE LOWER(%s)
                    )
            )
        ORDER BY m.titel;
        """
        
        search_pattern = f'%{query}%'
        cur.execute(sql, (search_pattern, search_pattern, search_pattern, search_pattern))
        
        medien = []
        for row in cur.fetchall():
            medium = {
                'medium_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'erscheinungsjahr': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'barcode': row[6],
                'notizen': row[7],
                'autoren': row[8] if row[8] else ''
            }
            medien.append(medium)
        
        cur.close()
        conn.close()
        
        return template('medien', title=f'Suchergebnisse für: {query}', medien=medien)
    except Exception as e:
        return template('error', error=str(e))

if __name__ == '__main__':
    app.run(host='localhost', port=8082, debug=True)
