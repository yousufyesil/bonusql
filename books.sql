CREATE TYPE zustand AS ENUM ('sehr gut', 'gut','akzeptabel','stark gebraucht','defekt','N/A');

CREATE TABLE author(
   author_id SERIAL PRIMARY KEY,
   name varchar(50));

CREATE TABLE sammelband(
    sammelband_id SERIAL,
    sammelband varchar(50),

    --  Ich gehe davon aus, dass die Bandnr sich auf den Sammelband bezieht

    PRIMARY KEY (sammelband_id));

CREATE TABLE verlag(
    verlag_id SERIAL,
    name varchar(50),
    verlagsort varchar(50),
    PRIMARY KEY (verlag_id));

CREATE TABLE books(
    BuchID SERIAL,
    title varchar(150) NOT NULL,
    seiten int NOT NULL CHECK (seiten > 0),
    author_id int,
    verlag_id int,
    year int,
    lang varchar(2) NOT NULL CHECK (lang ~ '^[a-zA-Z]{2}$'),  -- erlaubt Groß- und Kleinbuchstaben
    isbn varchar(20),
    herausgeber varchar(50),
    serie varchar(50),
    udk varchar(50),
    sammelband_id int,
    bandnr int,
    umschlag varchar(100),
    notes text,
    zustand zustand,
    FOREIGN KEY (verlag_id) REFERENCES verlag (verlag_id),
    FOREIGN KEY (author_id) REFERENCES author (author_id),
    FOREIGN KEY (sammelband_id) REFERENCES sammelband (sammelband_id),
    PRIMARY KEY (BuchID));

CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    FOREIGN KEY (book_id) REFERENCES books(BuchID),
    FOREIGN KEY (author_id) REFERENCES author(author_id),
    PRIMARY KEY (book_id, author_id)
);

-- Insert Authors
INSERT INTO author(name)
VALUES('Kenneth W Ford'),
('Michael F.G. Syrjakow'),
('Timothy Zahn'),
('Chris J Date');


INSERT INTO verlag (name, verlagsort)
VALUES
('Ullstein Buchverlage', 'Berlin'),
('Goldmann', 'München');
-- Insert Books
INSERT INTO sammelband(sammelband)
VALUES('Star Wars: Secrets of the Galaxy'),
      ('Star Trek Captains');

INSERT INTO books (
    title,
    seiten,
    author_id,
    year,
    verlag_id,
    lang,
    isbn,
    serie,
    sammelband_id,
    notes,
    zustand
)
    VALUES
    (
        'Wie klein ist klein?: Eine kurze Geschichte der Quanten',
        368,
        1,                  -- author_id für Kenneth W Ford
        2008,
        1,                  -- verlag_id für Verlag XYZ
        'de',
        '9783550087158',
        NULL,               -- Keine Serie
        NULL,               -- Kein Sammelband
        'Verdammt interessant',
        'gut'               -- Zustand muss einem Wert aus ENUM entsprechen
    ),
    (
        'Erben des Imperiums',
        416,
        3,                  -- author_id für Timothy Zahn
        1991,
        2,                  -- verlag_id für Verlag ABC
        'de',
        ' 9783442413348',
        'Thrawn-Trilogie',
        NULL,
        'Ein Meisterwerk',
        'sehr gut'          -- Zustand muss einem Wert aus ENUM entsprechen
    ),
    (
        'Relational Database: Selected Writings',
        497,
        4,
        1986,-- verlag_id für Verlag XYZ
        NULL,
        'en',
        9780201141962,
        NULL,
        NULL,
        'Für Fans von Relvars',
        'akzeptabel'
    );


