-- Datenbank erstellen
CREATE DATABASE bonusql;

-- Verbindung zur Datenbank herstellen
\c bonusql;

-- Tabellen erstellen
CREATE TABLE medien (
    medium_id SERIAL PRIMARY KEY,
    titel VARCHAR(300) NOT NULL,
    medientyp VARCHAR(50) NOT NULL,
    autor VARCHAR(200),
    erscheinungsjahr INTEGER,
    verlag VARCHAR(200),
    isbn VARCHAR(20),
    barcode VARCHAR(50) UNIQUE
);

CREATE TABLE personen (
    person_id SERIAL PRIMARY KEY,
    vorname VARCHAR(100),
    nachname VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    telefon VARCHAR(50)
);

CREATE TABLE ausleihen (
    ausleihe_id SERIAL PRIMARY KEY,
    medium_id INTEGER REFERENCES medien(medium_id),
    person_id INTEGER REFERENCES personen(person_id),
    ausleihdatum DATE NOT NULL,
    rueckgabedatum DATE NOT NULL,
    rueckgegeben BOOLEAN DEFAULT false,
    CONSTRAINT valid_dates CHECK (rueckgabedatum >= ausleihdatum)
);

-- Beispieldaten einfügen
INSERT INTO medien (titel, medientyp, autor, erscheinungsjahr, verlag, isbn, barcode) VALUES
    ('Der Herr der Ringe', 'Buch', 'J.R.R. Tolkien', 1954, 'Klett-Cotta', '978-3608939842', '9783608939842'),
    ('The Dark Side of the Moon', 'CD', 'Pink Floyd', 1973, 'Harvest Records', NULL, '724382975229'),
    ('Inception', 'DVD', 'Christopher Nolan', 2010, 'Warner Bros.', NULL, '5051429101935');

INSERT INTO personen (vorname, nachname, email, telefon) VALUES
    ('Max', 'Mustermann', 'max.mustermann@example.com', '+49123456789'),
    ('Erika', 'Musterfrau', 'erika.musterfrau@example.com', '+49987654321');

INSERT INTO ausleihen (medium_id, person_id, ausleihdatum, rueckgabedatum) VALUES
    (1, 1, '2025-01-01', '2025-01-15'),
    (2, 2, '2025-01-05', '2025-01-19');
