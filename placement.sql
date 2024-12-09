/*Ich gehe davon aus, dass sich in einem Regel verschiedene Medientypen befinden.
 Dies birgt das Problem, dass Items nicht anhand der ID eindeutig identifiziert werden können
 da es keine Globale Identifier gibt. Daher führe ich Type-Flags ein, welche eine eindeutige Zuordnung
  zu den lokalen IDs ermöglicht.
  */

CREATE TYPE item AS ENUM ('B', 'C', 'D','O');

CREATE table regal(
    room varchar(20),
    RegalID SERIAL PRIMARY KEY

);
CREATE table reihe(
    RegalID int,
    item_id int,
    item_type item,
    FOREIGN KEY (RegalID) REFERENCES regal (RegalID),
    PRIMARY KEY(item_id,item_type)

)