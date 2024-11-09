CREATE TABLE books(
    title varchar(50) NOT NULL,
    sites int NOT NULL,
    author varchar(50) NOT NULL,
    year int NOT NULL,
    verlag varchar(50) NOT NULL,
    lang varchar(2) NOT NULL,
    isbn varchar(13) NOT NULL,
    udk varchar(10),
    PRIMARY KEY (isbn,udk),

);

CREATE TABLE verlag(
    name varchar(50) NOT NULL,
    verlag_id int NOT NULL AUTO_INCREMENT,
    FOREIGN KEY (verlag_id) REFERENCES books(isbn),
    PRIMARY KEY (verlag_id),
);

CREATE TABLE authors(
    author_id int NOT NULL AUTO_INCREMENT,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    FOREIGN KEY (author_id) REFERENCES books(isbn),
    PRIMARY KEY (author_id),
);



-- Insert --

INSERT INTO books(title, sites, author, year,verlag, lang, isbn, udk)
VAlUES
   -- Was wenn ein Verlag noch nicht existiert?
    ('Star Wars - Erben des Imperiums', 590, 'Timothy Zahn', 2013,'Blanvalet','DE', '9783442269143', NULL),
    ('Star Wars: Die Hohe Republik - In die Dunkelheit', 416, 'Claudia Gray',  2021,'Panini','DE', '9783736798847', NULL),
    ('Star Wars: The High Republic: Into the Dark', 352, 'Timothy Zahn', 2021,'Disney Book Group','EN', '9781368062091', NULL),
    ('Star Wars: Der Funke des Widerstands', 368, 'Justina Ireland', 2019,'Panini','DE', '9783736799134', NULL),
    ('Star Wars: Spark of the Resistance', 224, 'Justina Ireland', 2019, 'Egmont', 'EN', '97814052-95420', NULL),

INSERT INTO authors(first_name, last_name)
VALUES
    ('Timothy', 'Zahn'),
    ('Claudia', 'Gray'),
    ('Justina', 'Ireland');

INSERT INTO verlag(name)
VALUES
    ('Blanvalet'),
    ('Panini'),
    ('Disney Book Group'),
    ('Egmont');