<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mediensuche</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .media-card {
            transition: transform 0.2s;
            margin-bottom: 20px;
        }
        .media-card:hover {
            transform: translateY(-5px);
        }
        .search-container {
            background: linear-gradient(135deg, #6e8efb, #a777e3);
            padding: 3rem 0;
            margin-bottom: 2rem;
        }
        .badge {
            margin-right: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="search-container text-center text-white">
        <div class="container">
            <h1 class="mb-4">Mediensuche</h1>
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="input-group mb-3">
                        <input type="text" id="searchInput" class="form-control form-control-lg" placeholder="Suche nach Titel oder Person...">
                        <select id="mediaType" class="form-select form-select-lg" style="max-width: 150px;">
                            <option value="all">Alle</option>
                            <option value="Buch">Bücher</option>
                            <option value="CD">CDs</option>
                            <option value="DVD">DVDs</option>
                            <option value="Noten">Noten</option>
                            <option value="Sonstiges">Sonstiges</option>
                        </select>
                        <button class="btn btn-light btn-lg" type="button" onclick="performSearch()">Suchen</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div id="results" class="row">
            <!-- Hier werden die Suchergebnisse dynamisch eingefügt -->
        </div>
    </div>

    <script>
        // Führe initial eine leere Suche durch
        document.addEventListener('DOMContentLoaded', function() {
            performSearch();
        });

        function performSearch() {
            const query = document.getElementById('searchInput').value;
            const type = document.getElementById('mediaType').value;
            const resultsContainer = document.getElementById('results');

            // Lade-Animation anzeigen
            resultsContainer.innerHTML = '<div class="col-12 text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Laden...</span></div></div>';

            fetch('/api/search', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `query=${encodeURIComponent(query)}&type=${encodeURIComponent(type)}`
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('Received data:', data);  // Debug-Ausgabe
                resultsContainer.innerHTML = '';
                
                if (!data || !data.results) {
                    throw new Error('Ungültiges Datenformat empfangen');
                }

                if (data.results.length === 0) {
                    resultsContainer.innerHTML = '<div class="col-12 text-center"><h3>Keine Ergebnisse gefunden</h3></div>';
                    return;
                }

                data.results.forEach(item => {
                    const card = createMediaCard(item);
                    resultsContainer.innerHTML += card;
                });
            })
            .catch(error => {
                console.error('Error:', error);
                resultsContainer.innerHTML = `
                    <div class="col-12 text-center">
                        <div class="alert alert-danger" role="alert">
                            <h4>Ein Fehler ist aufgetreten</h4>
                            <p>${error.message}</p>
                        </div>
                    </div>`;
            });
        }

        function createMediaCard(item) {
            const zustandBadgeClass = getZustandBadgeClass(item.zustand);
            return `
                <div class="col-md-4">
                    <div class="card media-card">
                        <div class="card-body">
                            <h5 class="card-title">${escapeHtml(item.titel)}</h5>
                            ${item.autoren ? `<p class="card-text"><strong>Von:</strong> ${escapeHtml(item.autoren)}</p>` : ''}
                            ${item.rollen ? `<p class="card-text"><small class="text-muted">Rollen: ${escapeHtml(item.rollen)}</small></p>` : ''}
                            <div class="mb-2">
                                <span class="badge bg-primary">${escapeHtml(item.medientyp)}</span>
                                ${item.datentraeger ? `<span class="badge bg-secondary">${escapeHtml(item.datentraeger)}</span>` : ''}
                                ${item.zustand ? `<span class="badge ${zustandBadgeClass}">${escapeHtml(item.zustand)}</span>` : ''}
                            </div>
                            ${item.erscheinungsjahr ? `<p class="card-text"><small class="text-muted">Erscheinungsjahr: ${item.erscheinungsjahr}</small></p>` : ''}
                        </div>
                    </div>
                </div>
            `;
        }

        function getZustandBadgeClass(zustand) {
            switch(zustand) {
                case 'sehr gut': return 'bg-success';
                case 'gut': return 'bg-info';
                case 'akzeptabel': return 'bg-warning';
                case 'stark gebraucht': return 'bg-danger';
                case 'defekt': return 'bg-dark';
                default: return 'bg-secondary';
            }
        }

        function escapeHtml(unsafe) {
            if (!unsafe) return '';
            return unsafe
                .toString()
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        // Suchauslösung bei Enter-Taste
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                performSearch();
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
