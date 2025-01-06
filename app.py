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
def home():
    return template('index')

# Ausleihen-Seite
@app.route('/loans')
def loans():
    return template('loans')

# API-Endpunkte
@app.route('/medien')
def get_media():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                m.medium_id, 
                m.titel, 
                m.medientyp, 
                string_agg(CONCAT(p.vorname, ' ', p.nachname), '; ') as autoren,
                m.erscheinungsjahr,
                v.name as verlag,
                b.isbn,
                m.barcode
            FROM medium m
            LEFT JOIN buch b ON m.medium_id = b.medium_id AND m.medientyp = b.medientyp
            LEFT JOIN verlag v ON b.verlag_id = v.verlag_id
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id AND m.medientyp = mpr.medientyp
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            LEFT JOIN ausleihe a ON m.medium_id = a.medium_id AND m.medientyp = a.medientyp 
                AND a.rueckgabe_datum IS NULL
            WHERE a.medium_id IS NULL
            GROUP BY m.medium_id, m.titel, m.medientyp, m.erscheinungsjahr, v.name, b.isbn, m.barcode
            ORDER BY m.titel;
        """)
        
        medien = []
        for row in cur.fetchall():
            medien.append({
                'medium_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'autor': row[3],
                'erscheinungsjahr': row[4],
                'verlag': row[5],
                'isbn': row[6],
                'barcode': row[7]
            })
        
        cur.close()
        conn.close()
        
        return {'success': True, 'medien': medien}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/search')
def search_media():
    try:
        query = request.query.q
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        search_term = f"%{query}%"
        cur.execute("""
            SELECT 
                m.medium_id, 
                m.titel, 
                m.medientyp, 
                string_agg(CONCAT(p.vorname, ' ', p.nachname), '; ') as autoren,
                m.erscheinungsjahr,
                v.name as verlag,
                b.isbn,
                m.barcode
            FROM medium m
            LEFT JOIN buch b ON m.medium_id = b.medium_id AND m.medientyp = b.medientyp
            LEFT JOIN verlag v ON b.verlag_id = v.verlag_id
            LEFT JOIN medium_person_role mpr ON m.medium_id = mpr.medium_id AND m.medientyp = mpr.medientyp
            LEFT JOIN person p ON mpr.person_id = p.person_id
            LEFT JOIN role r ON mpr.role_id = r.role_id
            LEFT JOIN ausleihe a ON m.medium_id = a.medium_id AND m.medientyp = a.medientyp 
                AND a.rueckgabe_datum IS NULL
            WHERE a.medium_id IS NULL
            AND (
                LOWER(m.titel) LIKE LOWER(%s)
                OR LOWER(CONCAT(p.vorname, ' ', p.nachname)) LIKE LOWER(%s)
                OR LOWER(b.isbn) LIKE LOWER(%s)
                OR LOWER(m.barcode) LIKE LOWER(%s)
            )
            GROUP BY m.medium_id, m.titel, m.medientyp, m.erscheinungsjahr, v.name, b.isbn, m.barcode
            ORDER BY m.titel;
        """, (search_term, search_term, search_term, search_term))
        
        medien = []
        for row in cur.fetchall():
            medien.append({
                'medium_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'autor': row[3],
                'erscheinungsjahr': row[4],
                'verlag': row[5],
                'isbn': row[6],
                'barcode': row[7]
            })
        
        cur.close()
        conn.close()
        
        return {'success': True, 'medien': medien}
    except Exception as e:
        return {'success': False, 'error': str(e)}

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

@app.route('/get_loans')
def get_loans():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT 
                a.ausleihe_id,
                m.titel,
                m.medientyp,
                p.vorname,
                p.nachname,
                a.ausleih_datum,
                a.ausleih_datum + INTERVAL '14 days' as rueckgabe_datum_soll,
                a.rueckgabe_datum
            FROM ausleihe a
            JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
            JOIN person p ON a.person_id = p.person_id
            WHERE a.rueckgabe_datum IS NULL
            ORDER BY a.ausleih_datum;
        """)
        
        loans = []
        for row in cur.fetchall():
            loans.append({
                'ausleihe_id': row[0],
                'titel': row[1],
                'medientyp': row[2],
                'vorname': row[3],
                'nachname': row[4],
                'ausleihdatum': row[5].strftime('%Y-%m-%d'),
                'rueckgabedatum': row[6].strftime('%Y-%m-%d'),
                'rueckgegeben': row[7] is not None
            })
        
        cur.close()
        conn.close()
        
        return {'success': True, 'loans': loans}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/return_media', method='POST')
def return_media():
    try:
        data = request.json
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            UPDATE ausleihe
            SET rueckgabe_datum = CURRENT_DATE
            WHERE ausleihe_id = %s;
        """, (data['ausleihe_id'],))
        
        conn.commit()
        cur.close()
        conn.close()
        
        return {'success': True}
    except Exception as e:
        return {'success': False, 'error': str(e)}

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
