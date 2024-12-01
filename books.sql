CREATE TYPE zustand AS ENUM ('sehr gut', 'gut','akzeptabel','stark gebraucht','defekt');

CREATE TABLE books(
    BuchID SERIAL,
    title varchar(150) NOT NULL,
    seiten int NOT NULL,
    -- author varchar(50),
    author_id int,
    verlag_id int,
    year int,
    lang varchar(2) NOT NULL,
    isbn varchar(20),
    herausgeber varchar(50),
    serie varchar(50),
    udk varchar(50),
    sammelband_id int,
    bandnr int,
    umschlag varchar(100),
    notes varchar(100),
    zustand zustand,
    FOREIGN KEY (verlag_id) REFERENCES verlag (verlag_id),
    FOREIGN KEY (author_id) REFERENCES authors (author_id),
    FOREIGN KEY (sammelband_id) REFERENCES sammelband (sammelband_id),
    PRIMARY KEY (BuchID));


CREATE TABLE sammelband(
    sammelband_id SERIAL,
    sammelband varchar(50),

    --  Ich gehe davon aus, dass die Bandnr sich auf den Sammelband bezieht

    PRIMARY KEY (sammelband_id)
);



CREATE TABLE verlag(
    verlag_id SERIAL,
    name varchar(50),
    verlagsort varchar(50),
    PRIMARY KEY (verlag_id)

);

CREATE TABLE authors(
   author_id SERIAL PRIMARY KEY,
   name varchar(50)
);

-- Insert Books

INSERT INTO books(title, sites, author, year, verlag_id, lang, isbn, sammelband, notes, BuchID) 
VALUES
('Wie klein ist klein?: Eine kurze Geschichte der Quanten', 368, 'Kenneth W Ford', 2008, 1, 'de', 9783550087158, false, 'Gebraucht', 'B0001'),
('Aufzeichnungen eines vagabundierenden Bewusstseins: Band 1: Eine schicksalhafte Begegnung ',124,'Michael F.G. Syrjakow',2019,2,'de', 9783947867011, false, NULL, 'B0002')


-- Insert Authors


INSERT INTO author(name)
VALUES('Kenneth W Ford'),
('Michael F.G. Syrjakow')
