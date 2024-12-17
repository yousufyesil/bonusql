## Bücher


```
Buch(Buch_ID, AuthorID, Genre, Serie, Release_Date, Length, Publisher, Type)
Author(AuthorID, Name, Birthdate, Country)
Verlag(VerlagID, Name, City)
Sammelband(Buch_ID, Title)
```
## CD

```
CD(CD_ID, ArtistID, TrackID, Genre, Release_Date, Length, Label, Type)
```
```
CD_Artist(ArtistID, Name, Birthdate, Country)
```
```
Track(TrackID, Title, Length, Genre)
```
```
CD_Track(CD_ID, TrackID)
```


## DVD





## Medienlokalisierung 
In der Sammlung werden die Entitäten klassisch in Regalen aufbewahrt. Um ein Medium in diesem System zu finden,
existiert die Relation _Regal_ und _Reihe_. Bei der Implementierung dieses Systems wurde ich mit der Herausforderung
konfrontiert, dass verschiedene Medien den gleichen Primary Key haben können und daher in einer gemeinsamen Tabelle nicht
eindeutig unterscheidbar wären. Um dies zu umgehen habe ich einen Type_Identifier eingeführt, welcher jeder Entität einen
Medientypen zuweist. Durch dieses Attribut kann ich meine Medien nicht nur global eindeutig unterscheiden, sondern auch 
spezifisch nach einzelnen Medientypen suchen. Aus diesem Grund ist auch ein gemeinsamer Primärschlüssel aus _ItemID_ und
_ItemType_ notwendig.

An dieser Stelle eignet sich auch der Verweis auf den Aufgabenabschnitt 2, welcher sich mit der Frage der Unterscheidung
einzelner Entitäten befasst. Diese wird durch die Type_Identifier sichergestellt, da eine eindeutige Zuordnung der Entitäten
zwischen den verschiedenen Entiäten ermölglicht. An dieser Stelle erscheint es sicherlich nicht fern, in die Item_ID der
einzelnen Entitäten den Typ einzupflegen. Diese Lösung wäre zwar durchaus valide, allerdings gehen uns dadurch Funktionen
verloren, da wir die ID als Varchar behandeln müssen, während wir ohne den Type_Identifier arithmetische Methoden auf die 
IDs anwenden können.


```
CREATE TYPE item AS ENUM ('B', 'C', 'D','O');
```
```
Regal(Regal_ID, Room)
```
```
Items(Item_ID, Item_Type, Regal_ID)
```


## Ausleihen
```
Person(Person_ID, name, tel, adress,birth_date)
```
```
Ausleihen(Ausleih_ID, Item_ID, Item_Type, Person_ID, Start_Date, End_Date)
```


## Python Schnittstelle

Zugriff auf die Dtenbank erfolgt mit psycopg2
Funktionen um die Datenbank zu manipulieren
addReihe()
addRegal()


