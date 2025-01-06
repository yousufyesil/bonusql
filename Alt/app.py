from bottle import Bottle, template, static_file, request, response
import psycopg2
from datetime import datetime
import json

app = Bottle()

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

# Statische Dateien bereitstellen
@app.route('/static/<filename:path>')
def serve_static(filename):
    
    return static_file(filename, root='./static')

# Hauptseite
@app.route('/')
def index():
    if request.headers.get('Accept') == 'application/json':
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            cur.execute("""
                SELECT 
                    m.medium_id,
                    m.medientyp::text,
                    m.titel,
                    m.erscheinungsjahr,
                    m.datentraeger::text,
                    m.zustand::text,
                    m.barcode,
                    m.notizen,
                    CASE 
                        WHEN EXISTS (
                            SELECT 1 
                            FROM ausleihe a 
                            WHERE a.medium_id = m.medium_id 
                            AND a.medientyp = m.medientyp 
                            AND a.rueckgabe_datum IS NULL
                        ) THEN true
                        ELSE false
                    END as ist_ausgeliehen
                FROM medium m
                ORDER BY m.titel;
            """)
            
            media = []
            for row in cur.fetchall():
                media.append({
                    'medium_id': row[0],
                    'medientyp': row[1],
                    'titel': row[2],
                    'erscheinungsjahr': row[3],
                    'datentraeger': row[4],
                    'zustand': row[5],
                    'barcode': row[6],
                    'notizen': row[7],
                    'ist_ausgeliehen': row[8]
                })
            
            cur.close()
            conn.close()
            
            response.content_type = 'application/json'
            return json.dumps(media)
        except Exception as e:
            response.content_type = 'application/json'
            return json.dumps({'error': str(e)})
    else:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            cur.execute("""
                SELECT 
                    m.medium_id,
                    m.medientyp::text,
                    m.titel,
                    m.erscheinungsjahr,
                    m.datentraeger::text,
                    m.zustand::text,
                    m.barcode,
                    m.notizen,
                    CASE 
                        WHEN EXISTS (
                            SELECT 1 
                            FROM ausleihe a 
                            WHERE a.medium_id = m.medium_id 
                            AND a.medientyp = m.medientyp 
                            AND a.rueckgabe_datum IS NULL
                        ) THEN true
                        ELSE false
                    END as ist_ausgeliehen
                FROM medium m
                ORDER BY m.titel;
            """)
            
            media = []
            for row in cur.fetchall():
                media.append({
                    'medium_id': row[0],
                    'medientyp': row[1],
                    'titel': row[2],
                    'erscheinungsjahr': row[3],
                    'datentraeger': row[4],
                    'zustand': row[5],
                    'barcode': row[6],
                    'notizen': row[7],
                    'ist_ausgeliehen': row[8]
                })
            
            cur.close()
            conn.close()
            return template('index', media=media)
        except Exception as e:
            return template('error', error=str(e))

# Medien-Seite
@app.route('/medien')
def medien():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                m.medium_id,
                m.medientyp,
                m.titel,
                m.erscheinungsjahr,
                m.datentraeger,
                m.zustand,
                m.barcode,
                m.notizen,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM ausleihe a 
                        WHERE a.medium_id = m.medium_id 
                        AND a.medientyp = m.medientyp 
                        AND a.rueckgabe_datum IS NULL
                    ) THEN true
                    ELSE false
                END as ist_ausgeliehen
            FROM medium m
            ORDER BY m.titel;
        """)
        
        media = []
        for row in cur.fetchall():
            media.append({
                'medium_id': row[0],
                'medientyp': row[1],
                'titel': row[2],
                'erscheinungsjahr': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'barcode': row[6],
                'notizen': row[7],
                'ist_ausgeliehen': row[8]
            })
        
        cur.close()
        conn.close()
        return template('medien', media=media)
    except Exception as e:
        return template('error', error=str(e))

# Personen-Seite
@app.route('/persons')
def persons():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                p.person_id,
                p.vorname,
                p.nachname,
                p.geburtstag,
                p.notizen
            FROM person p
            ORDER BY p.nachname, p.vorname;
        """)
        
        persons = []
        for row in cur.fetchall():
            persons.append({
                'person_id': row[0],
                'vorname': row[1],
                'nachname': row[2],
                'geburtstag': row[3].strftime('%d.%m.%Y') if row[3] else None,
                'notizen': row[4]
            })
        
        cur.close()
        conn.close()
        return template('persons', persons=persons)
    except Exception as e:
        return template('error', error=str(e))

# Ausleihen-Seite
@app.route('/loans')
def loans():
    return template('loans')

# API-Endpunkte
@app.route('/get_loans')
def get_loans():
    try:
        filter_type = request.query.get('filter', 'current')
        conn = get_db_connection()
        cur = conn.cursor()
        
        query = """
            SELECT 
                a.medium_id,
                a.medientyp,
                a.ausleih_datum,
                a.rueckgabe_datum,
                pe.vorname,
                pe.nachname,
                pe.adresse,
                pe.telefon,
                m.titel
            FROM ausleihe a
            JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
            LEFT JOIN person_extern pe ON a.person_id = pe.person_id
        """
        
        if filter_type == 'current':
            query += " WHERE a.rueckgabe_datum IS NULL"
        elif filter_type == 'overdue':
            query += " WHERE a.rueckgabe_datum IS NULL AND a.ausleih_datum + INTERVAL '30 days' < CURRENT_DATE"
        elif filter_type == 'history':
            query += " WHERE a.rueckgabe_datum IS NOT NULL"
        
        query += " ORDER BY a.ausleih_datum DESC"
        
        cur.execute(query)
        
        loans = []
        for row in cur.fetchall():
            loan = {
                'medium_id': row[0],
                'medientyp': row[1],
                'ausleih_datum': row[2].strftime('%d.%m.%Y'),
                'rueckgabe_datum': row[3].strftime('%d.%m.%Y') if row[3] else None,
                'vorname': row[4],
                'nachname': row[5],
                'adresse': row[6],
                'telefon': row[7],
                'titel': row[8]
            }
            loans.append(loan)
        
        cur.close()
        conn.close()
        return {'success': True, 'loans': loans}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/get_persons')
def get_persons():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                p.person_id,
                p.vorname,
                p.nachname,
                p.geburtstag,
                p.notizen,
                string_agg(DISTINCT r.role_name, ', ') as rollen
            FROM person p
            LEFT JOIN medium_person_role mpr ON p.person_id = mpr.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            GROUP BY p.person_id, p.vorname, p.nachname, p.geburtstag, p.notizen
            ORDER BY p.nachname, p.vorname;
        """)
        
        persons = []
        for row in cur.fetchall():
            person = {
                'person_id': row[0],
                'vorname': row[1],
                'nachname': row[2],
                'geburtstag': row[3].strftime('%d.%m.%Y') if row[3] else None,
                'notizen': row[4],
                'rollen': row[5] if row[5] else ''
            }
            persons.append(person)
        
        cur.close()
        conn.close()
        return {'success': True, 'persons': persons}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/search_persons', method='GET')
def search_persons():
    search_term = request.query.get('q', '')
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        search_pattern = f"%{search_term}%"
        cur.execute("""
            SELECT 
                p.person_id,
                p.vorname,
                p.nachname,
                p.geburtstag,
                p.notizen
            FROM person p
            WHERE 
                LOWER(p.vorname) LIKE LOWER(%s) OR
                LOWER(p.nachname) LIKE LOWER(%s)
            ORDER BY p.nachname, p.vorname;
        """, (search_pattern, search_pattern))
        
        persons = []
        for row in cur.fetchall():
            persons.append({
                'person_id': row[0],
                'vorname': row[1],
                'nachname': row[2],
                'geburtstag': row[3].strftime('%d.%m.%Y') if row[3] else None,
                'notizen': row[4]
            })
        
        cur.close()
        conn.close()
        
        response.content_type = 'application/json'
        return json.dumps({'success': True, 'persons': persons})
    except Exception as e:
        response.content_type = 'application/json'
        return json.dumps({'success': False, 'error': str(e)})

@app.route('/search_loans', method='GET')
def search_loans():
    search_term = request.query.get('q', '')
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        search_pattern = f"%{search_term}%"
        cur.execute("""
            SELECT 
                a.ausleihe_id,
                m.titel,
                p.vorname || ' ' || p.nachname as person_name,
                m.medientyp,
                a.ausleihdatum,
                a.rueckgabe_datum
            FROM ausleihe a
            JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
            JOIN person p ON a.person_id = p.person_id
            WHERE 
                LOWER(m.titel) LIKE LOWER(%s) OR
                LOWER(p.vorname || ' ' || p.nachname) LIKE LOWER(%s)
            ORDER BY a.ausleihdatum DESC;
        """, (search_pattern, search_pattern))
        
        loans = []
        for row in cur.fetchall():
            loans.append({
                'ausleihe_id': row[0],
                'titel': row[1],
                'person_name': row[2],
                'medientyp': row[3],
                'ausleihdatum': row[4].strftime('%d.%m.%Y'),
                'rueckgabe_datum': row[5].strftime('%d.%m.%Y') if row[5] else None
            })
        
        cur.close()
        conn.close()
        
        response.content_type = 'application/json'
        return json.dumps({'success': True, 'loans': loans})
    except Exception as e:
        response.content_type = 'application/json'
        return json.dumps({'success': False, 'error': str(e)})

@app.route('/get_borrowers')
def get_borrowers():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                p.person_id,
                p.vorname,
                p.nachname
            FROM person p
            JOIN person_extern pe ON p.person_id = pe.person_id
            ORDER BY p.nachname, p.vorname;
        """)
        
        borrowers = []
        for row in cur.fetchall():
            borrowers.append({
                'person_id': row[0],
                'vorname': row[1],
                'nachname': row[2]
            })
        
        cur.close()
        conn.close()
        
        return {'success': True, 'borrowers': borrowers}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/add_borrower', method='POST')
def add_borrower():
    try:
        data = request.json
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Person einfügen
        cur.execute("""
            INSERT INTO person (vorname, nachname)
            VALUES (%s, %s)
            RETURNING person_id;
        """, (data['vorname'], data['nachname']))
        
        person_id = cur.fetchone()[0]
        
        # Person_extern einfügen
        cur.execute("""
            INSERT INTO person_extern (person_id, email, telefon)
            VALUES (%s, %s, %s);
        """, (person_id, data['email'], data.get('telefon')))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return {'success': True, 'person_id': person_id}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/lend', method='POST')
def lend_media():
    try:
        data = request.json
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Prüfe, ob das Medium bereits ausgeliehen ist
        cur.execute("""
            SELECT COUNT(*)
            FROM ausleihe
            WHERE medium_id = %s 
            AND medientyp = %s 
            AND rueckgabe_datum IS NULL;
        """, (data['medium_id'], data['medientyp']))
        
        if cur.fetchone()[0] > 0:
            return {'success': False, 'error': 'Das Medium ist bereits ausgeliehen'}
        
        # Neue Ausleihe eintragen
        cur.execute("""
            INSERT INTO ausleihe (
                medium_id,
                medientyp,
                person_id,
                ausleih_datum
            ) VALUES (%s, %s, %s, %s);
        """, (
            data['medium_id'],
            data['medientyp'],
            data['person_id'],
            data['ausleihdatum']
        ))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return {'success': True}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/search')
def search():
    try:
        search_term = request.query.get('q', '')
        if not search_term:
            return {'success': True, 'medien': []}
            
        search_pattern = f"%{search_term}%"
        conn = get_db_connection()
        cur = conn.cursor()
        
        query = """
            SELECT 
                m.medium_id,
                m.medientyp,
                m.titel,
                m.erscheinungsjahr,
                m.datentraeger,
                m.zustand,
                m.notizen,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM ausleihe a 
                        WHERE a.medium_id = m.medium_id 
                        AND a.medientyp = m.medientyp 
                        AND a.rueckgabe_datum IS NULL
                    ) THEN true
                    ELSE false
                END as ist_ausgeliehen
            FROM medium m
            WHERE 
                LOWER(m.titel) LIKE LOWER(%s)
                OR LOWER(COALESCE(m.notizen, '')) LIKE LOWER(%s)
            ORDER BY m.titel;
        """
        
        cur.execute(query, (search_pattern, search_pattern))
        
        medien = []
        for row in cur.fetchall():
            medium = {
                'medium_id': row[0],
                'medientyp': row[1],
                'titel': row[2],
                'erscheinungsjahr': row[3],
                'datentraeger': row[4],
                'zustand': row[5],
                'notizen': row[6],
                'ist_ausgeliehen': row[7]
            }
            medien.append(medium)
        
        cur.close()
        conn.close()
        
        response.content_type = 'application/json'
        return {'success': True, 'medien': medien}
    except Exception as e:
        response.content_type = 'application/json'
        return {'success': False, 'error': str(e)}

@app.route('/get_available_media')
def get_available_media():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT m.medium_id, m.medientyp, m.titel
            FROM medium m
            LEFT JOIN ausleihe a ON m.medium_id = a.medium_id 
                AND m.medientyp = a.medientyp 
                AND a.rueckgabe_datum IS NULL
            WHERE a.medium_id IS NULL
            ORDER BY m.titel;
        """)
        
        media = []
        for row in cur.fetchall():
            media.append({
                'medium_id': row[0],
                'medientyp': row[1],
                'titel': row[2]
            })
        
        cur.close()
        conn.close()
        return {'success': True, 'media': media}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/search_media')
def search_media():
    try:
        search_term = f"%{request.query.get('q', '')}%"
        conn = get_db_connection()
        cur = conn.cursor()
        
        query = """
            SELECT 
                m.medium_id,
                m.medientyp,
                m.titel,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM ausleihe a 
                        WHERE a.medium_id = m.medium_id 
                        AND a.medientyp = m.medientyp 
                        AND a.rueckgabe_datum IS NULL
                    ) THEN true
                    ELSE false
                END as ist_ausgeliehen
            FROM medium m
            WHERE LOWER(m.titel) LIKE LOWER(%s)
            ORDER BY m.titel;
        """
        
        cur.execute(query, (search_term,))
        
        media = []
        for row in cur.fetchall():
            media.append({
                'medium_id': row[0],
                'medientyp': row[1],
                'titel': row[2],
                'ist_ausgeliehen': row[3]
            })
        
        cur.close()
        conn.close()
        return {'success': True, 'media': media}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/add_borrower', method='POST')
def add_borrower():
    try:
        data = request.json
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO person_extern (
                vorname,
                nachname,
                adresse,
                telefon,
                geburtsdatum,
                notizen
            ) VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING person_id;
        """, (
            data['vorname'],
            data['nachname'],
            data['adresse'],
            data['telefon'],
            data['geburtsdatum'] if data['geburtsdatum'] else None,
            data['notizen']
        ))
        
        person_id = cur.fetchone()[0]
        
        conn.commit()
        cur.close()
        conn.close()
        return {'success': True, 'person_id': person_id}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/add_loan', method='POST')
def add_loan():
    try:
        data = request.json
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Prüfen ob das Medium bereits ausgeliehen ist
        cur.execute("""
            SELECT 1 FROM ausleihe 
            WHERE medium_id = %s 
            AND medientyp = %s 
            AND rueckgabe_datum IS NULL;
        """, (data['medium_id'], data['medientyp']))
        
        if cur.fetchone():
            return {'success': False, 'error': 'Dieses Medium ist bereits ausgeliehen.'}
        
        # Neue Ausleihe erstellen
        cur.execute("""
            INSERT INTO ausleihe (
                medium_id,
                medientyp,
                person_id,
                ausleih_datum
            ) VALUES (%s, %s, %s, %s);
        """, (
            data['medium_id'],
            data['medientyp'],
            data['person_id'],
            data['ausleih_datum']
        ))
        
        conn.commit()
        cur.close()
        conn.close()
        return {'success': True}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/return_loan', method='POST')
def return_loan():
    try:
        data = request.json
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            UPDATE ausleihe 
            SET rueckgabe_datum = CURRENT_DATE
            WHERE medium_id = %s 
            AND medientyp = %s 
            AND rueckgabe_datum IS NULL;
        """, (data['medium_id'], data['medientyp']))
        
        if cur.rowcount == 0:
            return {'success': False, 'error': 'Keine aktive Ausleihe für dieses Medium gefunden.'}
        
        conn.commit()
        cur.close()
        conn.close()
        return {'success': True}
    except Exception as e:
        return {'success': False, 'error': str(e)}

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
