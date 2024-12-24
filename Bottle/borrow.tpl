<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bibliotheksverwaltung - Ausleihe</title>
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

        .borrow-container {
            background-color: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }

        .section-header {
            margin-bottom: 1.5rem;
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.5rem;
        }

        /* Formular-Styling */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
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
            padding: 0.75rem;
            border: 1px solid #cbd5e0;
            border-radius: 4px;
            font-size: 1rem;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52,152,219,0.2);
        }

        /* Tabellen-Styling */
        .table-container {
            overflow-x: auto;
            margin-top: 1.5rem;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
            background-color: white;
        }

        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        th {
            background-color: #34495e;
            color: white;
        }

        tbody tr:hover {
            background-color: #f8fafc;
        }

        /* Button-Styling */
        .button-group {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            margin-top: 1.5rem;
        }

        .button {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.2s;
        }

        .button-primary {
            background-color: #3498db;
            color: white;
        }

        .button-success {
            background-color: #2ecc71;
            color: white;
        }

        .button-danger {
            background-color: #e74c3c;
            color: white;
        }

        .button:hover {
            filter: brightness(110%);
            transform: translateY(-1px);
        }

        .button:active {
            transform: translateY(0);
        }

        /* Status-Badges */
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
        }

        .status-borrowed {
            background-color: #fed7d7;
            color: #c53030;
        }

        .status-available {
            background-color: #c6f6d5;
            color: #2f855a;
        }

        footer {
            background-color: #2c3e50;
            color: white;
            text-align: center;
            padding: 1rem;
            margin-top: auto;
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
        <a href="/borrow">Ausleihe</a>
    </nav>

    <main>
        <!-- Ausleihe-Sektion -->
        <section class="borrow-container">
            <h2 class="section-header">Neue Ausleihe</h2>
            <form id="borrowForm">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="itemId">Item ID / Barcode</label>
                        <input type="text" id="itemId" name="itemId" required>
                    </div>
                    <div class="form-group">
                        <label for="userId">Benutzer ID</label>
                        <input type="text" id="userId" name="userId" required>
                    </div>
                    <div class="form-group">
                        <label for="borrowDate">Ausleihdatum</label>
                        <input type="date" id="borrowDate" name="borrowDate" required>
                    </div>
                    <div class="form-group">
                        <label for="dueDate">Rückgabedatum</label>
                        <input type="date" id="dueDate" name="dueDate" required>
                    </div>
                </div>
                <div class="button-group">
                    <button type="button" class="button button-primary" onclick="checkAvailability()">Verfügbarkeit prüfen</button>
                    <button type="submit" class="button button-success">Ausleihen</button>
                </div>
            </form>
        </section>

        <!-- Rückgabe-Sektion -->
        <section class="borrow-container">
            <h2 class="section-header">Rückgabe</h2>
            <form id="returnForm">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="returnItemId">Item ID / Barcode</label>
                        <input type="text" id="returnItemId" name="returnItemId" required>
                    </div>
                    <div class="form-group">
                        <label for="returnDate">Rückgabedatum</label>
                        <input type="date" id="returnDate" name="returnDate" required>
                    </div>
                </div>
                <div class="button-group">
                    <button type="submit" class="button button-success">Rückgabe bestätigen</button>
                </div>
            </form>
        </section>

        <!-- Aktuelle Ausleihen -->
        <section class="borrow-container">
            <h2 class="section-header">Aktuelle Ausleihen</h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Item ID</th>
                            <th>Titel</th>
                            <th>Ausgeliehen an</th>
                            <th>Ausleihdatum</th>
                            <th>Rückgabedatum</th>
                            <th>Status</th>
                            <th>Aktionen</th>
                        </tr>
                    </thead>
                    <tbody id="borrowedItems">
                        <!-- Beispiel-Eintrag -->
                        <tr>
                            <td>B12345</td>
                            <td>Der Herr der Ringe</td>
                            <td>Max Mustermann</td>
                            <td>01.12.2024</td>
                            <td>15.12.2024</td>
                            <td><span class="status-badge status-borrowed">Ausgeliehen</span></td>
                            <td>
                                <button class="button button-danger">Rückgabe</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <footer>
        <p>&copy; 2024 Bibliotheksverwaltung</p>
    </footer>
</body>
</html>