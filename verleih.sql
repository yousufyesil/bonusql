-- Personen für die Ausleihe
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    telefon VARCHAR(20)
);

-- Ausleihen
CREATE TABLE ausleihe (
    ausleihe_id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES person(person_id),
    medium_id INTEGER NOT NULL,
    medium_typ item NOT NULL,
    ausleih_datum DATE NOT NULL DEFAULT CURRENT_DATE,
    rueckgabe_datum DATE,
    
    -- Ein Medium kann nicht zweimal gleichzeitig ausgeliehen sein
    UNIQUE (medium_id, medium_typ) WHERE rueckgabe_datum IS NULL,
    
    -- Rückgabedatum muss nach Ausleihdatum liegen
    CHECK (rueckgabe_datum IS NULL OR rueckgabe_datum >= ausleih_datum)
);

-- Index für aktive Ausleihen
CREATE INDEX idx_aktive_ausleihen ON ausleihe(medium_id, medium_typ) 
WHERE rueckgabe_datum IS NULL;