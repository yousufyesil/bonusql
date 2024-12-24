-- Medientypen für Filme
CREATE TYPE film_medium_type AS ENUM ('VHS', 'DVD', 'BD');

-- Filme und deren physische Medien in einer Tabelle
CREATE TABLE film_medium (
    medium_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_year INTEGER,
    director VARCHAR(100),
    medium_type film_medium_type NOT NULL,
    imdb_id VARCHAR(10),
    zustand zustand DEFAULT 'N/A'
);

-- Index für Titelsuche
CREATE INDEX idx_film_title ON film_medium(title);

-- Beispieldaten
INSERT INTO film_medium (title, release_year, director, medium_type, zustand) VALUES
    ('Inception', 2010, 'Christopher Nolan', 'BD', 'sehr gut'),
    ('Pulp Fiction', 1994, 'Quentin Tarantino', 'DVD', 'gut');