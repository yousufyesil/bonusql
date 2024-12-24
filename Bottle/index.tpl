<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bibliotheksverwaltung</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            background-color: #f5f5f5;
        }

        header {
            background-color: #2c3e50;
            color: white;
            padding: 1rem;
            text-align: center;
        }

        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            gap: 2rem;
            padding: 2rem;
        }

        /* Container für die oberen Buttons */
        .top-buttons {
            display: flex;
            gap: 2rem;
            justify-content: center;
            max-width: 640px; /* Begrenzt die maximale Breite */
            width: 100%;
        }

        .button {
            font-size: 1.5rem;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1rem;
        }

        /* Stil für die oberen Buttons */
        .top-button {
            padding: 2rem 3rem;
            flex: 1; /* Gleiche Breite für beide oberen Buttons */
            min-width: 250px;
        }

        /* Spezieller Stil für den Ausleih-Button */
        .borrow-button {
            padding: 1.5rem;
            width: 100%; /* Nimmt die volle Breite des Containers ein */
            max-width: 640px; /* Gleiche maximale Breite wie .top-buttons */
            flex-direction: row; /* Horizontale Ausrichtung von Icon und Text */
            justify-content: center;
        }

        .button:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .add-button {
            background-color: #27ae60;
            color: white;
        }

        .search-button {
            background-color: #2980b9;
            color: white;
        }

        .borrow-button {
            background-color: #8e44ad;
            color: white;
        }

        .icon {
            font-size: 2.5rem;
        }

        /* Spezieller Stil für das Icon im Ausleih-Button */
        .borrow-button .icon {
            margin-right: 1rem;
        }

        footer {
            background-color: #2c3e50;
            color: white;
            text-align: center;
            padding: 1rem;
            margin-top: auto;
        }

        /* Medienabfrage für responsive Design */
        @media (max-width: 768px) {
            .top-buttons {
                flex-direction: column;
                align-items: center;
            }

            .top-button {
                width: 100%;
            }

            .borrow-button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Bibliotheksverwaltung</h1>
    </header>

    <main>
        <div class="top-buttons">
            <a href="/add" class="button top-button add-button">
                <span class="icon">+</span>
                <span>Item hinzufügen</span>
            </a>
            <a href="/search" class="button top-button search-button">
                <span class="icon">🔍</span>
                <span>Item suchen</span>
            </a>
        </div>
        <a href="/borrow" class="button borrow-button">
            <span class="icon">📚</span>
            <span>Ausleihe</span>
        </a>
    </main>

    <footer>
        <p>&copy; 2024 Bibliotheksverwaltung</p>
    </footer>
</body>
</html>