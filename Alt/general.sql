SET client_encoding = 'UTF8';
<<<<<<< Updated upstream

CREATE TYPE medientyp AS ENUM ('Buch', 'CD', 'DVD', 'Noten', 'Sonstiges');
CREATE TYPE datentraeger AS ENUM ('VHS', 'DVD', 'BD', 'CD', 'Vinyl', 'Kassette', 'SACD', 'HiRes', 'Digital', 'Hardcover', 'Taschenbuch', 'Gebunden');
CREATE TYPE zustand AS ENUM ('sehr gut', 'gut', 'akzeptabel', 'stark gebraucht', 'defekt', 'N/A');

-- 2) PERSON
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    vorname VARCHAR(100),
    nachname VARCHAR(100) NOT NULL,
    geburtstag DATE,
    notizen TEXT,
    CONSTRAINT person_name CHECK (vorname IS NOT NULL OR nachname IS NOT NULL)
);

INSERT INTO person (vorname, nachname, geburtstag, notizen) VALUES
    ('Edgar Allan', 'Poe', '1809-01-19', 'Amerikanischer Schriftsteller'),
    ('Agatha', 'Christie', '1890-09-15', 'Krimi-Autorin'),
    ('Frédéric', 'Chopin', '1810-03-01', 'Komponist'),
    ('Wolfgang Amadeus', 'Mozart', '1756-01-27', 'Komponist'),
<<<<<<< Updated upstream
    ('Christopher', 'Nolan', '1970-07-30', 'Filmregisseur'),
    ('Max', 'Mustermann', NULL, NULL);

/* ENTFERNT: 
   CREATE TABLE autor (
       person_id INTEGER REFERENCES person(person_id),
       rolle VARCHAR(100),
       PRIMARY KEY (person_id, rolle)
   );

   INSERT INTO autor (person_id, rolle) VALUES
       (1, 'Autor'),  -- Edgar Allan Poe
       (2, 'Autor'),  -- Agatha Christie
       (6, 'Autor');  -- Max Mustermann
*/

CREATE TABLE verlag (
    verlag_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    ort VARCHAR(100),
    land VARCHAR(100)
);

INSERT INTO verlag (name, ort, land) VALUES
    ('Reclam', 'Stuttgart', 'Deutschland'),
    ('Henle', 'München', 'Deutschland'),
    ('Universal Edition', 'Wien', 'Österreich');

-- 4) MEDIUM
CREATE TABLE medium (
    medium_id SERIAL,
    medientyp medientyp NOT NULL,
    titel VARCHAR(300) NOT NULL,
    erscheinungsjahr INTEGER,
    datentraeger datentraeger,
    zustand zustand DEFAULT 'N/A',
    barcode VARCHAR(50) UNIQUE,
    notizen TEXT,
<<<<<<< Updated upstream
    PRIMARY KEY (medium_id, medientyp)
);

INSERT INTO medium (medientyp, titel, erscheinungsjahr, datentraeger, zustand, barcode) VALUES
    ('Buch', 'Der Untergang des Hauses Usher', 1839, 'Hardcover', 'gut', '9783150000001'),
    ('CD', 'Chopin: Complete Nocturnes', 1996, 'CD', 'sehr gut', '028947753742'),
    ('DVD', 'Inception', 2010, 'DVD', 'sehr gut', '5051429101935'),
    ('Buch', 'Test Buch', 2023, 'Hardcover', 'N/A', NULL);

-- 5) BUCH
CREATE TABLE buch (
    medium_id INTEGER,
    isbn VARCHAR(20),
    seiten INTEGER,
    sprache CHAR(2),    -- Hier nur 2 Zeichen (z.B. 'de')
    udk VARCHAR(50),
    serie VARCHAR(200),
    band_nr INTEGER,
    umschlag_bild TEXT,
    verlag_id INTEGER REFERENCES verlag(verlag_id),
    medientyp medientyp DEFAULT 'Buch',

    PRIMARY KEY (medium_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp),
    CONSTRAINT valid_pages CHECK (seiten > 0),
    CONSTRAINT valid_language CHECK (sprache ~ '^[a-zA-Z]{2}$'),
    CONSTRAINT valid_isbn CHECK (
        isbn IS NULL
        OR isbn ~ '^\d{10}$'
        OR isbn ~ '^\d{13}$'
        OR isbn ~ '^\d{9}X$'
    )
);

-- Anpassen der Sprache auf 2 Zeichen:
INSERT INTO buch (medium_id, isbn, seiten, sprache, verlag_id) VALUES
    (1, '9783150000001', 88, 'de', 1),
    (4, '1234567890', 200, 'de', NULL);

/* ENTFERNT:
   CREATE TABLE book_authors (
       book_id INTEGER REFERENCES buch(medium_id),
       author_id INTEGER REFERENCES autor(person_id),
       PRIMARY KEY (book_id, author_id)
   );

   INSERT INTO book_authors (book_id, author_id) VALUES
       (1, 1),
       (4, 6);
*/

CREATE TABLE sammelband (
    sammelband_id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL
);

INSERT INTO sammelband (titel) VALUES
    ('Edgar Allan Poe: Gesammelte Werke');

CREATE TABLE buch_sammelband (
    medium_id INTEGER REFERENCES buch(medium_id),
    sammelband_id INTEGER REFERENCES sammelband(sammelband_id),
    position INTEGER,
    PRIMARY KEY (medium_id, sammelband_id)
);

INSERT INTO buch_sammelband (medium_id, sammelband_id, position) VALUES
    (1, 1, 1);

-- 7) MUSIKWERK
CREATE TABLE musikwerk (
    werk_id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL,
    -- entfernt: komponist_id
    katalognummer VARCHAR(50),
    erscheinungsjahr INTEGER,
    verlag_id INTEGER REFERENCES verlag(verlag_id),
    notizen TEXT,
    CONSTRAINT valid_katalognummer CHECK (
        katalognummer IS NULL
        OR katalognummer ~ '^[A-Za-z]{1,4}\.?\s*\d{1,4}[a-z]?$'
    )
);

INSERT INTO musikwerk (titel, katalognummer, verlag_id) VALUES
    ('Fantaisie-Impromptu', 'Op. 66', 2);

CREATE TABLE werksatz (
    satz_id SERIAL PRIMARY KEY,
    werk_id INTEGER REFERENCES musikwerk(werk_id),
    satznummer INTEGER NOT NULL,
    bezeichnung VARCHAR(100),
    tempoangabe VARCHAR(50),
    notizen TEXT,
    UNIQUE(werk_id, satznummer),
    CONSTRAINT valid_satznummer CHECK (satznummer > 0)
);

INSERT INTO werksatz (werk_id, satznummer, bezeichnung, tempoangabe) VALUES
    (1, 1, 'Allegro agitato', 'Allegro agitato');

-- 8) TONTRAEGER
CREATE TABLE tontraeger (
    medium_id INTEGER,
    label VARCHAR(100),
    medientyp medientyp DEFAULT 'CD',
    PRIMARY KEY (medium_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp)
);

INSERT INTO tontraeger (medium_id, label) VALUES
    (2, 'Deutsche Grammophon');

-- Beispiel: CREATE TABLE track, falls benötigt
-- CREATE TABLE track (
--     medium_id INTEGER,
--     werk_id INTEGER,
--     tracknummer INTEGER NOT NULL,
--     dauer INTERVAL,
--     PRIMARY KEY (medium_id, werk_id, tracknummer)
-- );

INSERT INTO track (medium_id, werk_id, tracknummer, dauer) VALUES
    (2, 1, 1, '00:05:35');

-- 9) FILM
CREATE TABLE film (
    medium_id INTEGER,
    -- entfernt: regisseur_id
    imdb_id VARCHAR(10),
    laenge INTEGER,
    medientyp medientyp DEFAULT 'DVD',
    PRIMARY KEY (medium_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp),
    CONSTRAINT valid_imdb CHECK (imdb_id IS NULL OR imdb_id ~ '^tt\d{7,8}$'),
    CONSTRAINT valid_length CHECK (laenge > 0)
);

INSERT INTO film (medium_id, imdb_id, laenge) VALUES
    (3, 'tt1375666', 148);

-- 10) RAUM / REGAL / STANDORT
CREATE TABLE raum (
    raum_id SERIAL PRIMARY KEY,
    bezeichnung VARCHAR(100) NOT NULL,
    notizen TEXT
);

INSERT INTO raum (bezeichnung) VALUES
    ('Hauptbibliothek'),
    ('Musikzimmer');

CREATE TABLE regal (
    regal_id SERIAL PRIMARY KEY,
    raum_id INTEGER REFERENCES raum(raum_id),
    bezeichnung VARCHAR(100) NOT NULL,
    notizen TEXT
);

INSERT INTO regal (raum_id, bezeichnung) VALUES
    (1, 'Regal A'),
    (2, 'Notenregal');

CREATE TABLE standort (
    medium_id INTEGER,
    medientyp medientyp,
    regal_id INTEGER REFERENCES regal(regal_id),
    ebene INTEGER NOT NULL,
    position INTEGER,
    notizen TEXT,
    PRIMARY KEY (medium_id, medientyp),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp),
    CONSTRAINT valid_ebene CHECK (ebene > 0),
    CONSTRAINT valid_position CHECK (position IS NULL OR position > 0)
);

INSERT INTO standort (medium_id, medientyp, regal_id, ebene, position) VALUES
    (1, 'Buch', 1, 2, 5),
    (2, 'CD', 2, 1, 3),
    (3, 'DVD', 1, 3, 7);

-- 11) PERSON_EXTERN / AUSLEIHE
CREATE TABLE person_extern (
    person_id SERIAL PRIMARY KEY,
    vorname VARCHAR(100) NOT NULL,
    nachname VARCHAR(100) NOT NULL,
    adresse TEXT,
    telefon VARCHAR(50),
    geburtsdatum DATE,
    notizen TEXT
);

INSERT INTO person_extern (vorname, nachname, telefon) VALUES
    ('Max', 'Mustermann', '+49123456789'),
    ('Erika', 'Musterfrau', '+49987654321');

CREATE TABLE ausleihe (
    ausleihe_id SERIAL PRIMARY KEY,
    medium_id INTEGER,
    medientyp medientyp,
    person_id INTEGER REFERENCES person_extern(person_id),
    ausleih_datum DATE NOT NULL DEFAULT CURRENT_DATE,
    rueckgabe_datum DATE,
    notizen TEXT,
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp),
    CONSTRAINT valid_dates CHECK (
        rueckgabe_datum IS NULL OR
        rueckgabe_datum >= ausleih_datum
    )
);

INSERT INTO ausleihe (medium_id, medientyp, person_id, ausleih_datum, rueckgabe_datum) VALUES
    (1, 'Buch', 1, '2024-01-01', '2024-01-15'),
    (2, 'CD', 2, '2024-01-10', NULL);

-- 12) INDIZES
CREATE INDEX idx_medium_titel ON medium(titel);
CREATE INDEX idx_person_name ON person(nachname, vorname);
CREATE INDEX idx_standort_regal ON standort(regal_id, ebene, position);
CREATE INDEX idx_ausleihe_aktiv ON ausleihe(medium_id, medientyp) WHERE rueckgabe_datum IS NULL;

-- 13) VIEWS
CREATE VIEW aktive_ausleihen AS
SELECT
    a.ausleihe_id,
    m.titel,
    m.medientyp,
    p.vorname || ' ' || p.nachname AS person,
    a.ausleih_datum,
    a.notizen
FROM ausleihe a
JOIN medium m ON a.medium_id = m.medium_id AND a.medientyp = m.medientyp
JOIN person_extern p ON a.person_id = p.person_id
WHERE a.rueckgabe_datum IS NULL;

CREATE VIEW medien_standort AS
SELECT
    m.medium_id,
    m.medientyp,
    m.titel,
    r.bezeichnung AS regal,
    ra.bezeichnung AS raum,
    s.ebene,
    s.position
FROM medium m
JOIN standort s ON m.medium_id = s.medium_id AND m.medientyp = s.medientyp
JOIN regal r ON s.regal_id = r.regal_id
<<<<<<< Updated upstream
JOIN raum ra ON r.raum_id = ra.raum_id;

--------------------------------------------------------
-- NEU: ROLLEN-KONZEPT (statt autor/book_authors)
--------------------------------------------------------

-- a) Tabelle "role"
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Beispiel-Einträge (erweiterbar)
INSERT INTO role (role_name) VALUES
    ('Autor'),
    ('Komponist'),
    ('Regisseur');

-- b) Brückentabelle: medium_person_role
--    -> Bindet Medium (Buch/CD/DVD ...) an Person + Rolle
CREATE TABLE medium_person_role (
    medium_id INTEGER,
    medientyp medientyp,
    person_id INTEGER REFERENCES person(person_id),
    role_id INTEGER REFERENCES role(role_id),
    PRIMARY KEY (medium_id, medientyp, person_id, role_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp)
);

-- Beispiel: Edgar Allan Poe (person_id=1) ist "Autor" von medium_id=1 ("Der Untergang ...")
INSERT INTO medium_person_role (medium_id, medientyp, person_id, role_id)
SELECT 1, 'Buch', 1, role_id
FROM role
WHERE role_name = 'Autor';

-- Beispiel: Max Mustermann (person_id=6) ist "Autor" von medium_id=4 ("Test Buch")
INSERT INTO medium_person_role (medium_id, medientyp, person_id, role_id)
SELECT 4, 'Buch', 6, role_id
FROM role
WHERE role_name = 'Autor';

-- Beispiel: Christopher Nolan (person_id=5) ist "Regisseur" von medium_id=3 ("Inception")
INSERT INTO medium_person_role (medium_id, medientyp, person_id, role_id)
SELECT 3, 'DVD', 5, role_id
FROM role
WHERE role_name = 'Regisseur';

-- An dieser Stelle könnte man weitere Einträge vornehmen, 
-- z.B. Agatha Christie als Autorin eines Mediums (sobald es existiert), 
-- Christopher Nolan als Regisseur eines Mediums usw.
