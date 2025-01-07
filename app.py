#!/usr/bin/python3

import os
from bottle import route, run, template, request, static_file, response
import psycopg2
from psycopg2 import pool
import json
import datetime
import decimal

# Initialisiere den Connection Pool
try:
    connection_pool = psycopg2.pool.SimpleConnectionPool(
        minconn=1,
        maxconn=10,
        host="awsbase.cw6qjfqpxzus.us-east-1.rds.amazonaws.com",
        database="postgres",
        user="postgres",
        password="postgres",
        port="5432",
        sslmode="require",
        options="-c search_path=bonusql"
    )
except Exception as e:
    print(f"Error creating connection pool: {e}")
    connection_pool = None

def get_db_connection():
    if connection_pool:
        return connection_pool.getconn()
    else:
        # Fallback zur alten Verbindungsmethode
        return psycopg2.connect(
            host="awsbase.cw6qjfqpxzus.us-east-1.rds.amazonaws.com",
            database="postgres",
            user="postgres",
            password="postgres",
            port="5432",
            sslmode="require",
            options="-c search_path=bonusql"
        )

def return_db_connection(conn):
    if connection_pool and conn:
        connection_pool.putconn(conn)

# Füge eine Funktion zum Schließen des Pools hinzu
def close_pool():
    if connection_pool:
        connection_pool.closeall()

@route('/')
def home():
    return template('index')

@route('/sql')
def sql_page():
    return template('sql')

@route('/dashboard')
def dashboard():
    return template('dashboard')

@route('/locations')
def locations_dashboard():
    return template('locations')

@route('/api/all_media', method=['GET'])
def get_all_media():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        query = """
            SELECT DISTINCT m.medium_id, m.titel, m.erscheinungsjahr, m.medientyp::text, 
                   m.datentraeger::text, m.zustand::text,
                   string_agg(DISTINCT CONCAT_WS(' ', NULLIF(p.vorname, ''), p.nachname), ', ') as autoren,
                   string_agg(DISTINCT r.role_name, ', ') as rollen
            FROM medium m
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id 
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            GROUP BY m.medium_id, m.titel, m.erscheinungsjahr, m.medientyp, m.datentraeger, m.zustand
            ORDER BY m.titel
        """
        
        cur.execute(query)
        results = cur.fetchall()
        
        formatted_results = []
        for row in results:
            formatted_results.append({
                'medium_id': row[0],
                'titel': row[1],
                'erscheinungsjahr': row[2],
                'medientyp': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'autoren': row[6],
                'rollen': row[7]
            })

        cur.close()
        return_db_connection(conn)
        
        return json.dumps({'results': formatted_results})
    except Exception as e:
        print(f"Error fetching all media: {str(e)}")
        response.status = 500
        return json.dumps({'error': str(e), 'results': []})

@route('/api/lending_stats', method=['GET'])
def get_lending_stats():
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Aktuelle Ausleihen
        cur.execute("""
            SELECT 
                m.titel,
                COALESCE(pe.vorname, '') || ' ' || pe.nachname as ausgeliehen_an,
                a.ausleih_datum,
                a.rueckgabe_datum,
                CASE 
                    WHEN a.rueckgabe_datum IS NULL AND a.ausleih_datum + INTERVAL '30 days' < CURRENT_DATE 
                    THEN TRUE 
                    ELSE FALSE 
                END as ueberfaellig
            FROM ausleihe a
            JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
            JOIN person_extern pe ON a.person_id = pe.person_id
            WHERE a.rueckgabe_datum IS NULL
            ORDER BY a.ausleih_datum DESC;
        """)
        current_lendings = []
        for row in cur.fetchall():
            current_lendings.append({
                'titel': row[0],
                'ausgeliehen_an': row[1],
                'ausleihdatum': row[2].strftime('%d.%m.%Y') if row[2] else None,
                'rueckgabedatum': row[3].strftime('%d.%m.%Y') if row[3] else None,
                'ueberfaellig': row[4]
            })

        # Ausleihstatistiken
        cur.execute("""
            SELECT 
                COUNT(*) as gesamt_ausleihen,
                COUNT(CASE WHEN rueckgabe_datum IS NULL THEN 1 END) as aktuelle_ausleihen,
                COUNT(CASE 
                    WHEN rueckgabe_datum IS NULL 
                    AND ausleih_datum + INTERVAL '30 days' < CURRENT_DATE 
                    THEN 1 END) as ueberfaellige_ausleihen,
                COALESCE(
                    ROUND(
                        AVG(
                            CASE 
                                WHEN rueckgabe_datum IS NOT NULL 
                                THEN (rueckgabe_datum - ausleih_datum)
                            END
                        )::numeric
                    , 1)
                , 0) as durchschnittliche_ausleihdauer
            FROM ausleihe;
        """)
        stats = cur.fetchone()
        if not stats:
            stats = (0, 0, 0, 0)
        
        # Top Ausleiher
        cur.execute("""
            SELECT 
                COALESCE(pe.vorname, '') || ' ' || pe.nachname as name,
                COUNT(*) as anzahl_ausleihen
            FROM ausleihe a
            JOIN person_extern pe ON a.person_id = pe.person_id
            GROUP BY pe.person_id, pe.vorname, pe.nachname
            ORDER BY anzahl_ausleihen DESC
            LIMIT 5;
        """)
        top_borrowers = []
        for row in cur.fetchall():
            top_borrowers.append({
                'name': row[0],
                'anzahl_ausleihen': row[1]
            })

        # Meist ausgeliehene Medien
        cur.execute("""
            SELECT 
                m.titel,
                COUNT(*) as anzahl_ausleihen
            FROM ausleihe a
            JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
            GROUP BY m.medium_id, m.titel
            ORDER BY anzahl_ausleihen DESC
            LIMIT 5;
        """)
        top_media = []
        for row in cur.fetchall():
            top_media.append({
                'titel': row[0],
                'anzahl_ausleihen': row[1]
            })

        return json.dumps({
            'current_lendings': current_lendings,
            'stats': {
                'gesamt_ausleihen': int(stats[0]),
                'aktuelle_ausleihen': int(stats[1]),
                'ueberfaellige_ausleihen': int(stats[2]),
                'durchschnittliche_ausleihdauer': float(stats[3])
            },
            'top_borrowers': top_borrowers,
            'top_media': top_media
        }, default=str)
    except psycopg2.Error as db_err:
        print(f"Database error in get_lending_stats: {str(db_err)}")
        response.status = 500
        return json.dumps({'error': f"Datenbankfehler: {str(db_err)}"})
    except Exception as e:
        print(f"General error in get_lending_stats: {str(e)}")
        response.status = 500
        return json.dumps({'error': str(e)})
    finally:
        if cur:
            cur.close()
        if conn:
            return_db_connection(conn)

@route('/api/location_overview', method=['GET'])
def get_location_overview():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        query = """
            WITH standort_info AS (
                SELECT 
                    r.regal_id,
                    r.bezeichnung as regal_name,
                    ra.bezeichnung as raum_name,
                    s.ebene,
                    m.medium_id,
                    m.medientyp
                FROM regal r
                JOIN raum ra ON r.raum_id = ra.raum_id
                LEFT JOIN standort s ON r.regal_id = s.regal_id
                LEFT JOIN medium m ON s.medium_id = m.medium_id AND s.medientyp = m.medientyp
            )
            SELECT 
                regal_id,
                regal_name as standort_name,
                raum_name as raum,
                COUNT(DISTINCT medium_id) as anzahl_medien,
                string_agg(DISTINCT medientyp::text, ', ') as medientypen
            FROM standort_info
            GROUP BY regal_id, regal_name, raum_name
            ORDER BY raum_name, regal_name;
        """
        
        cur.execute(query)
        results = cur.fetchall()
        
        locations = []
        for row in results:
            locations.append({
                'standort_id': row[0],
                'standort_name': row[1],
                'raum': row[2],
                'anzahl_medien': row[3],
                'medientypen': row[4].split(', ') if row[4] else []
            })
        
        cur.close()
        return_db_connection(conn)
        
        response.content_type = 'application/json'
        return json.dumps({'locations': locations}, default=str)
    except Exception as e:
        return {'error': str(e)}

@route('/api/execute_sql', method=['POST'])
def execute_sql():
    try:
        query = request.forms.get('query', '').strip()
        if not query:
            response.status = 400
            return json.dumps({'error': 'Keine SQL-Abfrage angegeben'})

        # Überprüfe auf potenziell gefährliche Befehle
        dangerous_commands = ['DROP', 'DELETE', 'TRUNCATE', 'ALTER', 'CREATE', 'INSERT', 'UPDATE']
        if any(cmd in query.upper() for cmd in dangerous_commands):
            response.status = 403
            return json.dumps({'error': 'Diese Art von SQL-Befehl ist aus Sicherheitsgründen nicht erlaubt. Nur SELECT-Abfragen sind zulässig.'})

        conn = get_db_connection()
        cur = conn.cursor()
        
        try:
            cur.execute(query)
            
            # Prüfe, ob es sich um ein SELECT handelt
            if not cur.description:
                response.status = 400
                return json.dumps({'error': 'Nur SELECT-Abfragen sind erlaubt'})
            
            # Hole die Spaltennamen
            column_names = [desc[0] for desc in cur.description]
            
            # Hole die Ergebnisse
            results = cur.fetchall()
            
            # Formatiere die Ergebnisse als Liste von Dictionaries
            formatted_results = []
            for row in results:
                row_dict = {}
                for i, value in enumerate(row):
                    # Konvertiere spezielle PostgreSQL-Typen in String
                    if isinstance(value, (datetime.date, datetime.datetime)):
                        value = value.isoformat()
                    elif isinstance(value, decimal.Decimal):
                        value = float(value)
                    elif isinstance(value, (list, dict)):
                        value = json.dumps(value)
                    elif value is None:
                        value = None
                    else:
                        value = str(value)
                    row_dict[column_names[i]] = value
                formatted_results.append(row_dict)

            return json.dumps({
                'columns': column_names,
                'results': formatted_results,
                'rowCount': len(results)
            })
            
        except psycopg2.Error as db_err:
            print(f"Database error: {str(db_err)}")
            response.status = 400
            return json.dumps({'error': f"Datenbankfehler: {str(db_err)}"})
        finally:
            cur.close()
            return_db_connection(conn)
            
    except Exception as e:
        print(f"SQL execution error: {str(e)}")
        response.status = 500
        return json.dumps({'error': f"Fehler bei der Ausführung: {str(e)}"})

@route('/static/<filepath:path>')
def serve_static(filepath):
    return static_file(filepath, root='./static')

if __name__ == '__main__':
    print("Starting server...")
    try:
        run(host='localhost', port=8080, debug=True)
    finally:
        close_pool()
