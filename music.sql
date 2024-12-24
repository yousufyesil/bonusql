CREATE TYPE medientyp AS ENUM ('CD', 'Vinyl', 'Kassette', 'SACD', 'HiRes', 'Digital');

CREATE TABLE musikwerk (
    werk_id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL,
    komponist VARCHAR(100),
    katalognummer VARCHAR(50),
    erscheinungsjahr INTEGER,
    verlag VARCHAR(100),
    notizen TEXT,
    CONSTRAINT valid_katalognummer CHECK (katalognummer ~ '^[A-Z]{1,4}\s*\d{1,4}$')
);

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

CREATE TABLE disk (
    disk_id SERIAL PRIMARY KEY,
    titel VARCHAR(200) NOT NULL,
    medium_typ medientyp NOT NULL,
    erscheinungsjahr INTEGER,
    label VARCHAR(100),
    zustand zustand DEFAULT 'N/A',
    barcode VARCHAR(50) UNIQUE,
    sammlung VARCHAR(100),
    notizen TEXT
);

CREATE TABLE artist (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    typ VARCHAR(50),
    notizen TEXT
);

CREATE TABLE track (
    track_id SERIAL PRIMARY KEY,
    disk_id INTEGER REFERENCES disk(disk_id),
    werk_id INTEGER REFERENCES musikwerk(werk_id),
    satz_id INTEGER REFERENCES werksatz(satz_id),
    artist_id INTEGER REFERENCES artist(artist_id),
    track_nummer INTEGER NOT NULL,
    titel VARCHAR(200),
    dauer INTERVAL,
    aufnahmedatum DATE,
    notizen TEXT,
    UNIQUE(disk_id, track_nummer),
    CONSTRAINT werk_oder_satz CHECK (
        (werk_id IS NOT NULL AND satz_id IS NULL) OR
        (werk_id IS NULL AND satz_id IS NOT NULL)
    )
);