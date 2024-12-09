CREATE TYPE item AS ENUM ('B', 'C', 'D','O');

CREATE TABLE regal (
    RegalID SERIAL PRIMARY KEY
);

CREATE TABLE reihe (
    RegalID INT NOT NULL,
    item_id INT,
    item_type item NOT NULL,
    FOREIGN KEY (RegalID) REFERENCES regal (RegalID),
    PRIMARY KEY (RegalID, item_id, item_type)
);
CREATE TABLE person(
    PersonID SERIAL PRIMARY KEY,
    name varchar(50),
    number int,
    address varchar(50),
    city varchar(20)
);
CREATE TABLE ausleihen(
    leih_id SERIAL PRIMARY KEY,
    item_id int,
    item_type item,
    outgoing date,
    incoming date,
    person_id int
);


INSERT INTO regal DEFAULT VALUES;
INSERT INTO regal DEFAULT VALUES;
INSERT INTO regal DEFAULT VALUES;
INSERT INTO regal DEFAULT VALUES;


INSERT INTO reihe(regalid, item_id, item_type)
VALUES (1,1,'B'),
       (1,1,'C'),
       (2,2,'C'),
       (3,2,'C')

