<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bibliotheksverwaltung - Suche</title>
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

        nav {
            background-color: #34495e;
            padding: 0.5rem;
        }

        nav a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            margin-left: 1rem;
        }

        nav a:hover {
            background-color: #2c3e50;
            border-radius: 4px;
        }

        main {
            flex: 1;
            padding: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        .search-container {
            background-color: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .search-header {
            margin-bottom: 2rem;
        }

        .search-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .form-group label {
            font-weight: bold;
            color: #2c3e50;
        }

        .form-group input,
        .form-group select {
            padding: 0.5rem;
            border: 1px solid #bdc3c7;
            border-radius: 4px;
            font-size: 1rem;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52,152,219,0.3);
        }

        .search-buttons {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        .button {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: background-color 0.2s;
        }

        .search-btn {
            background-color: #2980b9;
            color: white;
        }

        .search-btn:hover {
            background-color: #3498db;
        }

        .reset-btn {
            background-color: #95a5a6;
            color: white;
        }

        .reset-btn:hover {
            background-color: #7f8c8d;
        }

        .results-container {
            margin-top: 2rem;
        }

        .results-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .results-table th,
        .results-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }

        .results-table th {
            background-color: #34495e;
            color: white;
        }

        .results-table tbody tr:hover {
            background-color: #f7f9fa;
        }

        footer {
            background-color: #2c3e50;
            color: white;
            text-align: center;
            padding: 1rem;
            margin-top: auto;
        }

        @media (max-width: 768px) {
            .search-form {
                grid-template-columns: 1fr;
            }

            .search-buttons {
                flex-direction: column;
            }

            .button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Bibliotheksverwaltung</h1>
    </header>

    <nav>
        <a href="/">Startseite</a>
        <a href="/add">Hinzufügen</a>
        <a href="/search">Suchen</a>
    </nav>

    <main>
        <div class="search-container">
            <div class="search-header">
                <h2>Item Suche</h2>
            </div>

            <form id="searchForm" class="search-form">
                <div class="form-group">
                    <label for="itemType">Item Typ</label>
                    <select id="itemType" name="itemType">
                        <option value="">Alle Typen</option>
                        <option value="book">Buch</option>
                        <option value="cd">CD</option>
                        <option value="dvd">DVD/BluRay</option>
                        <option value="notes">Noten</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="title">Titel</label>
                    <input type="text" id="title" name="title" placeholder="Titel eingeben...">
                </div>

                <div class="form-group">
                    <label for="author">Autor/Künstler</label>
                    <input type="text" id="author" name="author" placeholder="Autor oder Künstler eingeben...">
                </div>

                <div class="form-group">
                    <label for="isbn">ISBN/Katalognummer</label>
                    <input type="text" id="isbn" name="isbn" placeholder="ISBN oder Katalognummer eingeben...">
                </div>

                <div class="form-group">
                    <label for="location">Standort</label>
                    <select id="location" name="location">
                        <option value="">Alle Standorte</option>
                        <option value="room1">Raum 1</option>
                        <option value="room2">Raum 2</option>
                        <option value="room3">Raum 3</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="status">Status</label>
                    <select id="status" name="status">
                        <option value="">Alle</option>
                        <option value="available">Verfügbar</option>
                        <option value="borrowed">Ausgeliehen</option>
                    </select>
                </div>
            </form>

            <div class="search-buttons">
                <button type="button" class="button reset-btn" onclick="resetForm()">Zurücksetzen</button>
                <button type="button" class="button search-btn" onclick="searchItems()">Suchen</button>
            </div>
        </div>

        <div class="results-container">
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Typ</th>
                        <th>Titel</th>
                        <th>Autor/Künstler</th>
                        <th>ISBN/Katalognr.</th>
                        <th>Standort</th>
                        <th>Status</th>
                        <th>Aktionen</th>
                    </tr>
                </thead>
                <tbody id="resultsBody">
                    <!-- Ergebnisse werden hier dynamisch eingefügt -->
                </tbody>
            </table>
        </div>
    </main>

    <footer>
        <p>&copy; 2024 Bibliotheksverwaltung</p>
    </footer>
</body>
</html>