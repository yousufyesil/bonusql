/*Ich gehe davon aus, dass sich in einem Regel verschiedene Medientypen befinden.
 Dies birgt das Problem, dass Items nicht anhand der ID eindeutig identifiziert werden können
 da es keine Globale Identifier gibt. Daher führe ich Type-Flags ein, welche eine eindeutige Zuordnung
  zu den lokalen IDs ermöglicht.
  */

CREATE TYPE item AS ENUM ('B', 'C');

CREATE table regal(
    RegalID SERIAL PRIMARY KEY
);
CREATE table reihe(
    FOREIGN KEY (RegalID) REFERENCES regal (RegalID),
    item_type item
)