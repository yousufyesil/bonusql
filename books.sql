CREATE TABLE books(
    title varchar(150) NOT NULL,
    sites int NOT NULL,
    author varchar(50),
    author_id int,
    year int,
    verlag_id varchar(50),
    lang varchar(2) NOT NULL,
    isbn int,
    udk varchar(50),
    sammelband boolean,
    notes varchar(100),
    BuchID varchar(50),
    PRIMARY KEY (BuchID)

);
CREATE TABLE sammelband(
    werk varchar(50),
    BuchID varchar(50),
    AutorID int
);

CREATE TABLE verlag(
    name varchar(50),
    BuchID varchar(50),
    verlag_id int,
    FOREIGN KEY (BuchID) REFERENCES books (BuchID)
    PRIMARY KEY (verlag_id)

);

CREATE TABLE authors(
   author_id SERIAL,
   name varchar(50),
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
