<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BonusQL - Ausleihen</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    
    <!-- Custom CSS -->
    <style>
        .overdue {
            background-color: #ffe6e6;
        }
        .borrowed {
            background-color: #fff3cd;
        }
        .btn-group .active {
            background-color: #0d6efd;
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/">BonusQL</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="/">Medien</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="/loans">Ausleihen</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-outline-primary filter-btn active" data-status="all">Alle</button>
                    <button type="button" class="btn btn-outline-primary filter-btn" data-status="borrowed">Ausgeliehen</button>
                    <button type="button" class="btn btn-outline-primary filter-btn" data-status="overdue">Überfällig</button>
                </div>
            </div>
        </div>
        
        <div class="table-responsive">
            <table class="table" id="loansTable">
                <thead>
                    <tr>
                        <th>Medium</th>
                        <th>Typ</th>
                        <th>Ausleiher</th>
                        <th>Ausleihdatum</th>
                        <th>Rückgabedatum</th>
                        <th>Status</th>
                        <th>Aktionen</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Hier werden die Ausleihen dynamisch eingefügt -->
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script src="/static/loans.js"></script>
</body>
</html>
