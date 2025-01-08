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