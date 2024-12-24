-- Ein Standort fasst alle Positionsinformationen in einer Tabelle zusammen
CREATE TABLE standort (
    standort_id SERIAL PRIMARY KEY,
    zimmer VARCHAR(50) NOT NULL,
    regal_name VARCHAR(100) NOT NULL,  -- z.B. "Notenregal" oder "Zweites Regal rechts"
    ebene INTEGER NOT NULL,            -- Zählung von unten, z.B. 1, 2, 3...
    position INTEGER,                  -- Optional: Position von links auf der Ebene
    
    -- Referenz zum Medium
    medium_id INTEGER NOT NULL,
    medium_typ item NOT NULL,          -- Verwendet den existierenden ENUM-Typ
    
    -- Zusätzliche Informationen
    notiz TEXT,
    
    -- Ein Medium kann nur einmal irgendwo stehen
    UNIQUE(medium_id, medium_typ),
    
    -- Validierungen
    CHECK (ebene > 0),
    CHECK (position > 0)
);

-- Indizes für schnelle Suche
CREATE INDEX idx_standort_medium ON standort(medium_id, medium_typ);
CREATE INDEX idx_standort_location ON standort(zimmer, regal_name, ebene);
/*
 ALTER TABLE standort
ADD CONSTRAINT fk_medium
CHECK (
    (medium_typ = 'B' AND EXISTS (SELECT 1 FROM books WHERE BuchID = medium_id)) OR
    (medium_typ = 'C' AND EXISTS (SELECT 1 FROM cd WHERE DiskID = medium_id)) OR
    (medium_typ = 'D' AND EXISTS (SELECT 1 FROM dvd WHERE DVDID = medium_id))
);
 */