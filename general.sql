SET client_encoding = 'UTF8';
CREATE TYPE medientyp AS ENUM ('Buch', 'CD', 'DVD', 'Noten', 'Sonstiges');
CREATE TYPE datentraeger AS ENUM ('VHS', 'DVD', 'BD', 'CD', 'Vinyl', 'Kassette', 'SACD', 'HiRes', 'Digital', 'Hardcover', 'Taschenbuch', 'Gebunden');
CREATE TYPE zustand AS ENUM ('sehr gut', 'gut', 'akzeptabel', 'stark gebraucht', 'defekt', 'N/A');

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
    ('Christopher', 'Nolan', '1970-07-30', 'Filmregisseur');

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

CREATE TABLE medium (
    medium_id SERIAL,
    medientyp medientyp NOT NULL,
    titel VARCHAR(300) NOT NULL,
    erscheinungsjahr INTEGER,
    datentraeger datentraeger,
    zustand zustand DEFAULT 'N/A',
    barcode VARCHAR(50) UNIQUE,
    notizen TEXT,
    PRIMARY KEY (medium_id, medientyp),
    CONSTRAINT valid_year CHECK (erscheinungsjahr > 1400 AND erscheinungsjahr <= EXTRACT(YEAR FROM CURRENT_DATE))
);

INSERT INTO medium (medientyp, titel, erscheinungsjahr, datentraeger, zustand, barcode) VALUES
    ('Buch', 'Der Untergang des Hauses Usher', 1839, 'Hardcover', 'gut', '9783150000001'),
    ('CD', 'Chopin: Complete Nocturnes', 1996, 'CD', 'sehr gut', '028947753742'),
    ('DVD', 'Inception', 2010, 'DVD', 'sehr gut', '5051429101935');

CREATE TABLE buch (
    medium_id INTEGER,
    isbn VARCHAR(20),
    seiten INTEGER,
    sprache CHAR(2),
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
    CONSTRAINT valid_isbn CHECK (isbn IS NULL OR isbn ~ '^\d{10}$' OR isbn ~ '^\d{13}$' OR isbn ~ '^\d{9}X$')
);

INSERT INTO buch (medium_id, isbn, seiten, sprache, verlag_id) VALUES
    (1, '9783150000001', 88, 'de', 1);

CREATE TABLE buch_autor (
    medium_id INTEGER,
    person_id INTEGER REFERENCES person(person_id),
    rolle VARCHAR(50) DEFAULT 'Autor',
    PRIMARY KEY (medium_id, person_id),
    FOREIGN KEY (medium_id) REFERENCES buch(medium_id)
);

INSERT INTO buch_autor (medium_id, person_id) VALUES
    (1, 1);

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

CREATE TABLE musikwerk (
    werk_id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL,
    komponist_id INTEGER REFERENCES person(person_id),
    katalognummer VARCHAR(50),
    erscheinungsjahr INTEGER,
    verlag_id INTEGER REFERENCES verlag(verlag_id),
    notizen TEXT,
    CONSTRAINT valid_katalognummer CHECK (katalognummer IS NULL OR katalognummer ~ '^[A-Za-z]{1,4}\.?\s*\d{1,4}[a-z]?$')
);

INSERT INTO musikwerk (titel, komponist_id, katalognummer, verlag_id) VALUES
    ('Fantaisie-Impromptu', 3, 'Op. 66', 2);

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

CREATE TABLE tontraeger (
    medium_id INTEGER,
    label VARCHAR(100),
    medientyp medientyp DEFAULT 'CD',      -- Hier wurde DEFAULT hinzugefügt
    PRIMARY KEY (medium_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp)
);

INSERT INTO tontraeger (medium_id, label) VALUES
    (2, 'Deutsche Grammophon');

CREATE TABLE track (
    track_id SERIAL PRIMARY KEY,
    medium_id INTEGER REFERENCES tontraeger(medium_id),
    werk_id INTEGER REFERENCES musikwerk(werk_id),
    satz_id INTEGER REFERENCES werksatz(satz_id),
    tracknummer INTEGER NOT NULL,
    titel VARCHAR(200),
    dauer INTERVAL,
    aufnahmedatum DATE,
    interpret_id INTEGER REFERENCES person(person_id),
    dirigent_id INTEGER REFERENCES person(person_id),
    ensemble VARCHAR(200),
    notizen TEXT,
    UNIQUE(medium_id, tracknummer),
    CONSTRAINT werk_oder_satz CHECK ((werk_id IS NOT NULL AND satz_id IS NULL) OR (werk_id IS NULL AND satz_id IS NOT NULL))
);

INSERT INTO track (medium_id, werk_id, tracknummer, dauer) VALUES
    (2, 1, 1, '00:05:35');

CREATE TABLE film (
    medium_id INTEGER,
    regisseur_id INTEGER REFERENCES person(person_id),
    imdb_id VARCHAR(10),
    laenge INTEGER,
    medientyp medientyp DEFAULT 'DVD',

    PRIMARY KEY (medium_id),
    FOREIGN KEY (medium_id, medientyp) REFERENCES medium(medium_id, medientyp),
    CONSTRAINT valid_imdb CHECK (imdb_id IS NULL OR imdb_id ~ '^tt\d{7,8}$'),
    CONSTRAINT valid_length CHECK (laenge > 0)
);

INSERT INTO film (medium_id, regisseur_id, imdb_id, laenge) VALUES
    (3, 5, 'tt1375666', 148);

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

CREATE INDEX idx_medium_titel ON medium(titel);
CREATE INDEX idx_person_name ON person(nachname, vorname);
CREATE INDEX idx_standort_regal ON standort(regal_id, ebene, position);
CREATE INDEX idx_ausleihe_aktiv ON ausleihe(medium_id, medientyp) WHERE rueckgabe_datum IS NULL;

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
JOIN raum ra ON r.raum_id = ra.raum_id;