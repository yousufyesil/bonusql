<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Standort Dashboard - Medien Verwaltung</title>
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
                   <a class="nav-link" href="/dashboard">
                    <i class="bi bi-graph-up me-1"></i>Dashboard
                </a>
                <a class="nav-link active" href="/locations">
                    <i class="bi bi-geo-alt me-1"></i>Standorte
                </a>
             
                
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <!-- Übersichtskarten -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-geo-alt me-1"></i>Standorte Gesamt
                        </h6>
                        <h2 id="totalLocations" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-collection me-1"></i>Medien Gesamt
                        </h6>
                        <h2 id="totalMedia" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-box me-1"></i>Ø Medien pro Standort
                        </h6>
                        <h2 id="avgMediaPerLocation" class="card-title mb-0">-</h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- Standortübersicht -->
        <div class="row mb-4">
            <div class="col-12">
                <h3 class="mb-4">
                    <i class="bi bi-geo-alt me-2"></i>
                    Standortübersicht
                </h3>
                <div id="locationContainer" class="row">
                    <!-- Standortkarten werden hier dynamisch eingefügt -->
                </div>
            </div>
        </div>

        <!-- Medientypen-Verteilung -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0">
                            <i class="bi bi-pie-chart me-2"></i>Medientypen-Verteilung
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="mediaTypeDistribution">
                                <thead>
                                    <tr>
                                        <th>Standort</th>
                                        <th>Bücher</th>
                                        <th>DVDs</th>
                                        <th>CDs</th>
                                        <th>Noten</th>
                                        <th>Sonstiges</th>
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
    <script src="/static/locations.js"></script>
</body>
</html>
