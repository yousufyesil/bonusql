<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ausleihe Dashboard - Medien Verwaltung</title>
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
                <a class="nav-link" href="/">
                    <i class="bi bi-house-door me-1"></i>Home
                </a>
                <a class="nav-link" href="/sql">
                    <i class="bi bi-code-square me-1"></i>SQL
                </a>
                <a class="nav-link active" href="/dashboard">
                    <i class="bi bi-graph-up me-1"></i>Dashboard
                </a>
                <a class="nav-link" href="/locations">
                    <i class="bi bi-geo-alt me-1"></i>Standorte
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <!-- Statistik-Karten -->
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-calendar-check me-1"></i>Gesamt Ausleihen
                        </h6>
                        <h2 id="totalLendings" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-book me-1"></i>Aktuelle Ausleihen
                        </h6>
                        <h2 id="currentLendings" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-exclamation-triangle me-1"></i>Überfällig
                        </h6>
                        <h2 id="overdueLendings" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-clock-history me-1"></i>Ø Ausleihdauer
                        </h6>
                        <h2 id="avgLendingDuration" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-4">
            <!-- Aktuelle Ausleihen -->
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="bi bi-list-check me-2"></i>Aktuelle Ausleihen
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="currentLendingsTable">
                                <thead>
                                    <tr>
                                        <th>Titel</th>
                                        <th>Ausgeliehen an</th>
                                        <th>Ausleihdatum</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Wird durch JavaScript gefüllt -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Top Ausleiher -->
            <div class="col-md-6 mb-4">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="bi bi-people me-2"></i>Top Ausleiher
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="topBorrowersTable">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Anzahl Ausleihen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Wird durch JavaScript gefüllt -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Meist ausgeliehene Medien -->
            <div class="col-md-6 mb-4">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="bi bi-star me-2"></i>Meist ausgeliehene Medien
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="topMediaTable">
                                <thead>
                                    <tr>
                                        <th>Titel</th>
                                        <th>Anzahl Ausleihen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Wird durch JavaScript gefüllt -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/static/dashboard.js"></script>
</body>
</html>
