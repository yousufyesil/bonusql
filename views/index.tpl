<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medien Verwaltung</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="/">
                <i class="bi bi-collection-play me-2"></i>
                Medien Verwaltung
            </a>
            <div class="navbar-nav">
                <a class="nav-link active" href="/">
                    <i class="bi bi-house-door me-1"></i>Home
                </a>
                <a class="nav-link" href="/sql">
                    <i class="bi bi-code-square me-1"></i>SQL
                </a>
                <a class="nav-link" href="/dashboard">
                    <i class="bi bi-graph-up me-1"></i>Dashboard
                </a>
                <a class="nav-link" href="/locations">
                    <i class="bi bi-geo-alt me-1"></i>Standorte
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="search-card">
            <form id="searchForm" class="mb-4">
                <div class="row g-3">
                    <div class="col-md-8">
                        <div class="input-group">
                            <span class="input-group-text">
                                <i class="bi bi-search"></i>
                            </span>
                            <input type="text" id="searchQuery" class="form-control" placeholder="Suche nach Titel oder Autor...">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <select id="mediaType" class="form-select">
                            <option value="all">Alle Medientypen</option>
                            <option value="Buch">Bücher</option>
                            <option value="CD">CDs</option>
                            <option value="DVD">DVDs</option>
                            <option value="Noten">Noten</option>
                            <option value="Zeitschrift">Zeitschriften</option>
                        </select>
                    </div>
                </div>
            </form>
        </div>

        <div id="loadingSpinner" class="spinner d-none"></div>
        <div id="results">
            <!-- Ergebnisse werden hier dynamisch eingefügt -->
        </div>
    </div>

    <footer class="container mt-5 mb-4 text-center text-muted">
        <small> 2025 Medien Verwaltung. Alle Rechte vorbehalten.</small>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/static/app.js"></script>
</body>
</html>
