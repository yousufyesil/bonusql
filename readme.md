# Bonusaufgabe – Projektdokumentation (angepasst an **general.sql**)

## 1. Einleitung

In dieser Dokumentation wird eine **Datenbank** für eine Medien-Sammlung vorgestellt, die aus Büchern, CDs, DVDs, Noten etc. besteht. Das konkrete **Schema** liegt in der Datei `general.sql`. Dabei wurden bereits viele Entitäten und Beziehungen realisiert:

- **`medium`** als zentrale Tabelle, die jedes physische Objekt (Buch, CD, DVD usw.) repräsentiert – mithilfe eines Enums `medientyp` (`'Buch'`, `'CD'`, `'DVD'`, `'Noten'`, …).  
- **Spezialisierungstabellen** für die einzelnen Medientypen, z. B.:  
  - `buch` (z. B. ISBN, Seitenzahl, Verlag, …)  
  - `tontraeger` (für CDs u. a.)  
  - `film` (für DVDs und andere Filmmedien)  
- **Standort**-Verwaltung über `raum`, `regal`, `standort`.  
- **Ausleihe**-Funktion über `ausleihe`, verknüpft mit `person_extern`.  
- **Rollen-Konzept** (Autor, Komponist, Regisseur etc.) über `role`, `medium_person_role`, `musikwerk_person_role`.

Im Folgenden beschreiben wir kurz, **warum** dieses Design sinnvoll ist und **wie** wir damit die Fragen der Aufgabe beantworten können. Außerdem gehen wir auf die **theoretischen Aspekte** (Mehrfach-Autoren, Sammlungen, Normalisierung etc.) ein.

---

## 2. Datenbank-Schema (Übersicht)

### 2.1 Zentrale Tabelle `medium`

Alle Medien (Bücher, CDs, DVDs, Noten, Sonstiges) teilen sich die **Spalten**:  
- `medium_id` (SERIAL)  
- `medientyp` (ENUM: `'Buch'`, `'CD'`, `'DVD'`, `'Noten'`, …)  
- `titel` (z. B. der Buchtitel oder CD-Titel)  
- `erscheinungsjahr`, `datentraeger` (z. B. `'Hardcover'`, `'CD'`, `'DVD'` …)  
- `zustand`, `barcode`, `notizen`

**Primary Key** ist `(medium_id, medientyp)`. Damit kann ein Medium eindeutig unterschieden werden. Zusätzlich existiert eine `SERIAL`-Spalte `medium_id`, die für sich genommen schon eindeutig ist, aber da verschiedene `medientyp`-Werte an diese ID „andocken“ können, wurde der kombinierte PK gewählt.

### 2.2 Spezialisierungen

- **Tabelle `buch`**  
  Enthält Felder wie `isbn`, `seiten`, `sprache`, `udk`, `serie`, `band_nr`, `umschlag_bild` und `verlag_id`.  
  Primärschlüssel ist `medium_id` (1:1-Beziehung zu `medium`) plus `medientyp = 'Buch'` als Fremdschlüssel.  

- **Tabelle `tontraeger`**  
  Für CDs (oder andere Audio-Träger) gibt es `label` und ggf. weitere Felder. In der Datei `general.sql` heißt sie entsprechend `tontraeger`. Wiederum `(medium_id, medientyp)` wird mit `medium` verknüpft.  

- **Tabelle `film`**  
  Für DVDs/BDs/VHS etc. Enthält Felder wie `imdb_id`, `laenge` (Filmlaufzeit), `medientyp` mit Default `DVD`. Wieder `(medium_id, medientyp)` = PK + FK zu `medium`.

**Noten** können als `medientyp='Noten'` in `medium` eingetragen werden. Ob sie in `buch` oder eigener Tabelle landen, hängt davon ab, ob man sie buch-ähnlich behandelt (Seiten, Verlag usw.) oder anders. In `general.sql` wurde der Typ „Noten“ nur als Variant im Enum angelegt und kann analog genutzt werden.

### 2.3 Sammlungen (Sammelbände, Musikwerk, werksatz …)

- Für **Sammelbände** existiert `sammelband` plus Verknüpfungstabelle `buch_sammelband`. Damit lassen sich mehrere Bücher einer Reihe zuordnen.  
- Für **Musikwerke** (Kompositionen) existieren `musikwerk` und `werksatz`. Auf diese Weise kann man z. B. Komponisten, Katalognummern, Sätze usw. verwalten. Eine CD (in `tontraeger`) kann mehrere `track`-Datensätze enthalten, die wiederum auf `musikwerk` oder einzelne `werksatz`-Einträge zeigen.

### 2.4 Standort (Raum, Regal, Ebene, Position)

- **Tabelle `standort`** ordnet `(medium_id, medientyp)` einem `regal` (und damit einem `raum`) zu.  
- So kann jedes Medium an einem konkreten Ort gefunden werden.

### 2.5 Person, Ausleihe

- **Tabelle `person`**: interne Personen (z. B. Autoren, Komponisten).  
- **Tabelle `person_extern`**: externe Personen (z. B. Besucher), die etwas ausleihen können.  
- **Tabelle `ausleihe`**: `(medium_id, medientyp, person_id, ausleih_datum, rueckgabe_datum)`.  
  - `rueckgabe_datum = NULL` bedeutet, das Medium ist noch ausgeliehen.

### 2.6 Rollen-Konzept

- **Tabelle `role`** (z. B. „Autor“, „Komponist“, „Regisseur“).  
- **Tabelle `medium_person_role`**: Verknüpft ein Medium (Buch, CD, DVD etc.) mit einer Person (Autor, Komponist …). Damit lassen sich Mehrfach-Autoren abbilden.  
- **Tabelle `musikwerk_person_role`**: Für Komponisten und andere Rollen am Musikwerk (statt am Medium).

---

## 3. Theoretische Fragen & Antworten

### 3.1 Unterscheidung der Gegenstände (Bücher, CDs, DVDs, Noten usw.)

- **Frage**: „Warum nicht alles in einer großen Tabelle?“  
  **Antwort**: Prinzipiell ist das schon geschehen (Tabelle `medium`), aber für die spezifischen Felder (z. B. `seiten`, `isbn`) gibt es Folgetabellen (`buch`). So vermeidet man ein Übermaß an NULL-Spalten für abweichende Medien.

- **Frage**: „Was bringt der `medientyp`-ENUM?“  
  **Antwort**: Damit kann man einfach filtern, und man vermeidet Tippfehler bei der Eingabe. Auch sorgt es für eine klare Eingrenzung der erlaubten Typen.

### 3.2 Mehrere Autoren, Sammelbände

- **Mehrere Autoren** oder Regisseure etc. werden per `medium_person_role` abgebildet. Eine Person erhält dort die Rolle („Autor“).  
- **Sammelband**: Über `sammelband` und `buch_sammelband` kann man mehrere Bücher zu einem Band verknüpfen, nebst Position in der Reihe.

### 3.3 Standort

- Die Tabellen `raum` → `regal` → `standort` ermöglichen eine saubere Hierarchie.  
- Jedes Medium landet in genau einem `standort` (optional könnte man mehrere Standorte zulassen, aber hier ist ein Medium i. d. R. nur an einer Stelle zugleich).

### 3.4 Verleih

- **Ausleihe** unterscheidet laufende von beendeten Einträgen über `rueckgabe_datum IS NULL`.  
- Historie bleibt vollständig erhalten; man löscht nichts, sondern trägt nur das Enddatum ein.

### 3.5 Normalisierung

- Das Schema orientiert sich an mindestens der **3. Normalform**.  
- **Vorteil**: Vermeidet Redundanzen und Inkonsistenzen. So existieren z. B. Verlage in der eigenen Tabelle `verlag`, Personendaten in `person`/`person_extern`, etc.

---

## 4. Beispiel-Queries (Fragen aus der Aufgabe)

1. **Alle Bücher von „Edgar Allan Poe“, wo stehen sie?**  
   ```sql
   SELECT
       m.medium_id,
       m.titel,
       s.ebene,
       s.position,
       r.bezeichnung AS regal,
       ra.bezeichnung AS raum
   FROM medium m
   JOIN medium_person_role mpr
        ON  mpr.medium_id = m.medium_id
        AND mpr.medientyp = m.medientyp
   JOIN person p
        ON  p.person_id = mpr.person_id
   JOIN role ro
        ON  ro.role_id = mpr.role_id
   JOIN standort s
        ON  s.medium_id = m.medium_id
        AND s.medientyp = m.medientyp
   JOIN regal r
        ON  r.regal_id = s.regal_id
   JOIN raum ra
        ON  ra.raum_id = r.raum_id
   WHERE m.medientyp = 'Buch'
     AND ro.role_name = 'Autor'
     AND p.nachname ILIKE '%Poe%'
   ORDER BY m.medium_id;

# Datenbanken

## BonuSQL Infrastructure\
\
http://102.d
## Theoretische Fragen
*Macht es Sinn die Bücher in einer einzigen Tabelle zu speichern? Ein Datensatz würde dann doch genau einem Buch entsprechen, das ist doch super, oder?*  
<br>Eine essenzielle Eigenschaft beim Design einer Datenbank stellt die Datenintegrität dar. Sie sorgt dafür, dass Informationen konsistent und ohne Konflikte gespeichert werden. Daher ist es sinnvoll, dass gleichwertige Objekte mit den gleichen Tupeln in einer gemeinsamen Relation repräsentiert. Allerdings kann es auch Ausnahmen geben wie zum Beispiel Sammelbänder, welcher sich in bestimmten Eigenschaften von anderen Büchern zu stark abheben, wodurch eine Sicherung in einer eigenen Relation durchaus denkbar wäre. Allerdings erhöht sich dadurch auch unter Umständen Größe des Datenbanksystems, weshalb in Einzelfällen immer eine Kosten-Nutzen Abwägung nötig ist.

*‌Es gibt weitere Sachen, die aufbewahrt werden, dazugehören u.a. CDs,DVDs,Musiknoten. Es macht wohl Sinn die Gegenstände irgendwie zu unterscheiden. Zum Beispiel, ginge es anhand von einem Präfix im Primärschlüssel: Bücher werden B12345,CDs C12345 und etwa Noten N12345 nummeriert. Diskutieren Sie, inwieweit eine solche Lösung angebracht ist! Benennen Sie bessere Alternativen(und setzen Sie eins davon um)!*
<br><br>Eine eindeutige Unterscheidung der einzelnen Entitäten erfolgt bereits durch eigene Relationen, in welchen Sie über einen Index  als Primärschlüssel eindeutig zugeordnet werden können. Durch eine Zuordnung über Buchstabenpräfixe könnten diverse Nachteile entstehen, da uns die Vorteile des Datentyp Int verloren gehen könnten. Spätestens in der Implementierung der Datenbank könnte dies zu Problemen führen. Darüber hinaus müsste der Primärschlüssel jedes mal beim erstellen eines Datensatzes angegeben werden, wodurch auf der Anwendungsebene jedes mal überprüft werden müsste ob ein Schlüssel bereits existiert und einen entsprechenden Präfix vor die Nummer setzen würde. Eine angemessene Methode diese zu Unterscheiden kann allerdings unter Zuhilfenahme von Types erfolgen, so das sin einer Tabelle aus verschiedenen Medien anhand eines Types gefiltert werden kann, um was für eine Art Medium es sich handelt. Diese Lösung bietet uns insgesamt eine Verwaltung von Daten, welche unabhängiger vom Primärschlüssel ist, besser skalierter ist und gleichzeitig fähig ist verschiedene Medien klar trennen kann. An dieser Stelle ist allerdings zu erwähnen, dass eine Identifikation durch einen Präfix durchaus ein legitimes Mittel sein kann, um verschiedene Arten von Medien darzustellen.


*‌ Es gibt mehrere Schritte zwischen den ursprünglichen Design bzw. E/R-Modellierung und der finalen Umsetzung. Mitunter muss man die Relvars auf höhere und höhere Normalformen normalisieren. Welche Normalform verwenden Sie letztendlich und wieso? Welche Vorteile sind damit verbunden?*<br><br>
Während des Designs wär es stetig Ziel einen konsistenten Aufbau  der Relationen umzusetzen. Daher habe ich mich für eine Umsetzung in der dritten Normalform entschieden. Dies hat den Vorteil, dass Anomalien effektiv vorgebeugt werden können. Außerdem können Beziehungen zwischen Entitäten besser dargestellt werden und wodurch auch die Lesbarkeit profitiert und das System als gesamtes wartungsfreundlicher macht. Eine höhere Normalform wäre allerdings durchaus möglich gewesen, hierauf wurde allerdings verzichtet, da eine höhere Normalform auch die Folge hat, dass mehr Joins nötig sind um Informationen abrufen zu können. 

*Wie soll ein Design hier aussehen? Macht es Sinn, folgenden Ansatz zu wählen? Alle Ausleihen (Primärschlüssel, Fremdschlüssel für Person, Fremdschlüssel für Gegenstand, Datum des Anfangs, Datum des Endes) in einer Tabelle zu haben; aktive Ausleihen würden sich von den beendeten nur anhand von noch nicht eingetragener (NULL!) Ende der Leihe unterscheiden. Was ist hier falsch? Wie ginge es besser?*<br><br>

Eine Unterscheidung zwischen aktiven Ausleihen und beendete Ausleihen sollte selbst bei seltener Benutzung vorgenommen werden, da es die Lesbarkeit fördert. Darüber hinaus sollten in einer Relation möglichst gleichwertige Daten stehen, daher ergibt eine Trennung durchaus Sinn. Umsetzen könnte man dies durch Transaktionen, bei welchen bei einer Beendigung einer Ausleihe, der Eintrag automatisch einer Relation für abgeschlossene Ausleihen zugeordnet wird. Insbesondere wenn man ein Frontend anbinden möchte sollte hier klar unterschieden werden um eine Anbindung effizienter zu ermöglichen.

*‌ Angenommen, ich will alle Gegenstände katalogisieren und mit einem Barcode versehen. Verleih würde dann wie in der alten Bibliothek funktionieren, mit dem Scannen von Code. Wichtiger wäre aber wohl, dass man durch Scannen vom Code den ursprünglichen Standort vom Gegenstand herausfinden könnte. Gibt es irgendwelche Einschränkungen, die Ihr Design in diesem Kontext hergibt?*

Technisch ist dies durch ein Barcode-Attribut in einer Tabelle aller Medien möglich. Allerdings könnte die Vergabe der Barcodes Probleme machen, wenn diese auf ISBNs basieren sollen, da ältere Bücher i.d.R über keinen Barcode verfügen und hierbei intern ein Barcode ausgestellt werden muss. Diese Bücher müsste man für einen visuellen Scan allerdings auch mit mindestens einem Sticker versehen, was für ältere Sammlerstücke durchaus schade wäre und im schlimmsten Fall das Buch sogar beschädigen könnte. 

## Praktische Anbindung 
### Cloud Infrastruktur

Die Anbindung an ein Frontend erfolgt über eine Python Anwendung, in welcher die Datenbank mit psycopg2 angebunden werden kann. Um einen Zugriff auf die Datenbank von außerhalb zu ermöglichen, wird die Datenbank bei AWS auf der t3-Instanz gehostet. Unter Verwendung einer EC2 Instanz der Größe t3.nano kann eine Infrastruktur aufgebaut werden, in welcher durch eine Auto-Scaling Group und einem Loadbalancer die Performance des Systems sich an die Anforderungen anpassen kann. Die Speicherung der Buchumschläge könnte zudem in einem S3-Bucket erfolgen, welcher dann durch einen Referenz der Entität abgerufen werden könnte. 



   
