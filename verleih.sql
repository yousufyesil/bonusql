CREATE TYPE item AS ENUM ('B', 'C', 'D','O','N');

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
    person_id int,
    anmerkung varchar(100),
    FOREIGN KEY (person_id) REFERENCES person (PersonID)
);

