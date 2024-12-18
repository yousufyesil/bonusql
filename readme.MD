## Artist
```
Artist(Artist, Name, Birthdate, Country)
```
## Bücher
```
Buch(Buch_ID, AuthorID, Genre, Serie, Release_Date, Length, Publisher, Type)
```
```
Verlag(VerlagID, Name, City)
```
```
Sammelband(Buch_ID, Title)
```
## Audio_Disk

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


## Video_Disk
```
Type(DVD, BD, VHS)
```
```
DVD(Disk_ID,Name, Release,Writer, Director IMDb_Reference,Type)
```

### Umgang mit Medien anderen Typs
Für Medien, welche sich nicht in die gegebenen Kategorien (Buch, Audio, Video) einordnen lassen, wäre eine eigene Relation eine Lösung diese zu katalogisieren. Die Hürde hierbei besteht allerdings, dass die Entitäten sich auf gemeinsame Attribute einigen müssen. Hierfür sollten diese möglichst allgemein gehalten werden, da wir nicht für jede Entität eine eigene Relation erschaffen können. Mein Vorschlag wäre folgende Implementierung 
```
Other(Title,Release,Author,Notes)
```
## Musikstücke
```
Musikstück(Titel, Komponist, Untertitel, Herrausgeber, Katalognummer)
```

### Tabellenstruktur

Auf Grund der sich Teilweise überschneidenden Attribute, wäre es tatsächlich ein Gedanke wert, alle Relation _Disk_ anzulegen, welche CDs und DVDs sowie die dazugehörigen Medien vereinigt. Ich habe mich allerdings gegen dieses Design entschieden, mit der Begründung, dass sich CDs und DVDs in ihren Eigenschaften zu sehr unterscheiden, als das ich sie in eine gemeinsame Relation vereinen würde. Attribute wie _IMDb_Reference_ währen z.B nicht auf CDs anwendbar. Daher habe ich mich entscheiden Filmmedien und Tonmedien voneinander getrennt du behandeln.

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


