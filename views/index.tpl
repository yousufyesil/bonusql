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
                        <a class="nav-link active" href="/">Medien</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/loans">Ausleihen</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row mb-4">
            <div class="col">
                <div class="input-group">
                    <input type="text" id="searchInput" class="form-control" placeholder="Suche nach Titel, Autor, ISBN...">
                    <button class="btn btn-outline-secondary" type="button">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </div>
        </div>
        
        <div class="row mb-4">
            <div class="col">
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-outline-primary filter-btn active" data-type="all">Alle</button>
                    <button type="button" class="btn btn-outline-primary filter-btn" data-type="Buch">Bücher</button>
                    <button type="button" class="btn btn-outline-primary filter-btn" data-type="CD">CDs</button>
                    <button type="button" class="btn btn-outline-primary filter-btn" data-type="DVD">DVDs</button>
                </div>
            </div>
        </div>
        
        <div id="results">
            <!-- Hier werden die Suchergebnisse dynamisch eingefügt -->
        </div>
    </div>

    <!-- Ausleihe Dialog -->
    <div class="modal fade" id="lendDialog" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Medium ausleihen</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="lendForm" onsubmit="handleLend(event)">
                        <input type="hidden" id="lendMediumId">
                        <input type="hidden" id="lendMedientyp">
                        
                        <div class="mb-3">
                            <label for="borrowerSelect" class="form-label">Ausleiher</label>
                            <div class="input-group">
                                <select class="form-select" id="borrowerSelect" required>
                                    <option value="">Bitte wählen...</option>
                                </select>
                                <button type="button" class="btn btn-outline-secondary" onclick="showNewBorrowerForm()">
                                    <i class="bi bi-plus-lg"></i> Neu
                                </button>
                            </div>
                        </div>
                        
                        <!-- Formular für neuen Ausleiher -->
                        <div id="newBorrowerForm" style="display: none;">
                            <div class="mb-3">
                                <label for="borrowerFirstName" class="form-label">Vorname</label>
                                <input type="text" class="form-control" id="borrowerFirstName">
                            </div>
                            <div class="mb-3">
                                <label for="borrowerLastName" class="form-label">Nachname</label>
                                <input type="text" class="form-control" id="borrowerLastName">
                            </div>
                            <div class="mb-3">
                                <label for="borrowerEmail" class="form-label">E-Mail</label>
                                <input type="email" class="form-control" id="borrowerEmail">
                            </div>
                            <div class="mb-3">
                                <label for="borrowerPhone" class="form-label">Telefon</label>
                                <input type="tel" class="form-control" id="borrowerPhone">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="lendDate" class="form-label">Ausleihdatum</label>
                            <input type="date" class="form-control" id="lendDate" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="returnDate" class="form-label">Rückgabedatum</label>
                            <input type="date" class="form-control" id="returnDate" required>
                        </div>
                        
                        <div class="text-end">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Abbrechen</button>
                            <button type="submit" class="btn btn-primary">Ausleihen</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script src="/static/main.js"></script>
</body>
</html>
