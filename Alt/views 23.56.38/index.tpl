<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BonusQL - Medienverwaltung</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="/">
                <i class="bi bi-collection-fill"></i>
                BonusQL
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="/">
                            <i class="bi bi-grid-3x3-gap"></i>
                            Medien
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/loans">
                            <i class="bi bi-box-arrow-right"></i>
                            Ausleihen
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/persons">
                            <i class="bi bi-people"></i>
                            Personen
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row my-4">
            <div class="col">
                <div class="card shadow-sm">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Medienübersicht</h5>
                        <div class="input-group" style="max-width: 300px;">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="bi bi-search"></i>
                            </span>
                            <input type="text" class="form-control border-start-0" id="searchInput" placeholder="Suche nach Titel...">
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Titel</th>
                                        <th>Typ</th>
                                        <th>Jahr</th>
                                        <th>Datenträger</th>
                                        <th>Zustand</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    % for medium in media:
                                    <tr>
                                        <td>{{medium['titel']}}</td>
                                        <td>{{medium['medientyp']}}</td>
                                        <td>{{medium['erscheinungsjahr'] if medium['erscheinungsjahr'] else '-'}}</td>
                                        <td>{{medium['datentraeger'] if medium['datentraeger'] else '-'}}</td>
                                        <td>{{medium['zustand']}}</td>
                                        <td>
                                            % if medium['ist_ausgeliehen']:
                                                <span class="badge bg-danger">Ausgeliehen</span>
                                            % else:
                                                <span class="badge bg-success">Verfügbar</span>
                                            % end
                                        </td>
                                    </tr>
                                    % end
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    document.getElementById('searchInput').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const title = row.cells[0].textContent.toLowerCase();
            row.style.display = title.includes(searchTerm) ? '' : 'none';
        });
    });
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script src="/static/app.js"></script>
</body>
</html>
