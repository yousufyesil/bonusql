document.addEventListener('DOMContentLoaded', function() {
    const searchForm = document.getElementById('searchForm');
    const resultsDiv = document.getElementById('results');
    const searchQuery = document.getElementById('searchQuery');
    const mediaType = document.getElementById('mediaType');
    const loadingSpinner = document.getElementById('loadingSpinner');
    
    // Cache für alle Medien
    let allMediaData = [];

    // Initial alle Medien laden
    loadAllMedia();

    // Live-Suche bei Eingabe
    searchQuery.addEventListener('input', handleSearch);
    mediaType.addEventListener('change', handleSearch);

    // Verhindere Standard-Form-Submit
    searchForm.addEventListener('submit', (e) => {
        e.preventDefault();
        handleSearch();
    });

    async function loadAllMedia() {
        try {
            showLoading();
            const response = await fetch('/api/all_media');
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            allMediaData = data.results || [];
            displayResults(allMediaData);
        } catch (error) {
            console.error('Error loading all media:', error);
            showError(error.message);
        } finally {
            hideLoading();
        }
    }

    function handleSearch() {
        const query = searchQuery.value.toLowerCase().trim();
        const type = mediaType.value;

        // Filter die gecachten Daten
        const filteredResults = allMediaData.filter(item => {
            const matchesType = type === 'all' || item.medientyp === type;
            const matchesQuery = !query || 
                item.titel.toLowerCase().includes(query) ||
                (item.autoren && item.autoren.toLowerCase().includes(query));

            return matchesType && matchesQuery;
        });

        displayResults(filteredResults);
        updateResultCount(filteredResults.length);
    }

    function updateResultCount(count) {
        const countDisplay = document.getElementById('resultCount') || createResultCountElement();
        countDisplay.innerHTML = `
            <i class="bi bi-info-circle me-1"></i>
            ${count} ${count === 1 ? 'Medium' : 'Medien'} gefunden
        `;
    }

    function createResultCountElement() {
        const countDisplay = document.createElement('div');
        countDisplay.id = 'resultCount';
        countDisplay.className = 'text-muted mb-2';
        searchForm.insertAdjacentElement('afterend', countDisplay);
        return countDisplay;
    }

    function showLoading() {
        loadingSpinner.classList.remove('d-none');
        resultsDiv.classList.add('d-none');
    }

    function hideLoading() {
        loadingSpinner.classList.add('d-none');
        resultsDiv.classList.remove('d-none');
    }

    function showError(message) {
        resultsDiv.innerHTML = `
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle me-2"></i>
                ${escapeHtml(message)}
            </div>
        `;
    }

    function displayResults(results) {
        if (!results || results.length === 0) {
            resultsDiv.innerHTML = `
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    Keine Ergebnisse gefunden.
                </div>
            `;
            return;
        }

        let tableHTML = `
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th onclick="sortTable(0)" style="cursor: pointer">
                                <i class="bi bi-sort-alpha-down me-1"></i>Titel
                            </th>
                            <th onclick="sortTable(1)" style="cursor: pointer">
                                <i class="bi bi-tag me-1"></i>Typ
                            </th>
                            <th onclick="sortTable(2)" style="cursor: pointer">
                                <i class="bi bi-calendar me-1"></i>Jahr
                            </th>
                            <th onclick="sortTable(3)" style="cursor: pointer">
                                <i class="bi bi-people me-1"></i>Autoren
                            </th>
                            <th>
                                <i class="bi bi-disc me-1"></i>Datenträger
                            </th>
                            <th>
                                <i class="bi bi-star me-1"></i>Zustand
                            </th>
                        </tr>
                    </thead>
                    <tbody>
        `;

        results.forEach(item => {
            tableHTML += `
                <tr class="search-result">
                    <td>
                        <strong>${escapeHtml(item.titel)}</strong>
                    </td>
                    <td>
                        <span class="badge bg-primary">${escapeHtml(item.medientyp)}</span>
                    </td>
                    <td>${escapeHtml(item.erscheinungsjahr || '-')}</td>
                    <td>${escapeHtml(item.autoren || '-')}</td>
                    <td>
                        <span class="badge bg-secondary">${escapeHtml(item.datentraeger || '-')}</span>
                    </td>
                    <td>
                        <span class="badge ${getZustandBadgeClass(item.zustand)}">
                            ${escapeHtml(item.zustand || '-')}
                        </span>
                    </td>
                </tr>
            `;
        });

        tableHTML += `
                    </tbody>
                </table>
            </div>
        `;

        resultsDiv.innerHTML = tableHTML;
    }

    function getZustandBadgeClass(zustand) {
        switch (zustand) {
            case 'sehr gut':
                return 'bg-success';
            case 'gut':
                return 'bg-info';
            case 'akzeptabel':
                return 'bg-warning';
            case 'stark gebraucht':
                return 'bg-danger';
            case 'defekt':
                return 'bg-danger';
            default:
                return 'bg-secondary';
        }
    }

    function escapeHtml(unsafe) {
        if (unsafe === null || unsafe === undefined) return '';
        return unsafe
            .toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // CodeMirror-Editor initialisieren
    const editor = CodeMirror.fromTextArea(document.getElementById('sqlEditor'), {
        mode: 'text/x-sql',
        theme: 'dracula',
        lineNumbers: true,
        indentWithTabs: true,
        smartIndent: true,
        lineWrapping: true,
        matchBrackets: true,
        autofocus: true,
        extraKeys: {
            'Ctrl-Enter': executeQuery,
            'Cmd-Enter': executeQuery
        }
    });

    // Empfohlene Queries
    const recommendedQueries = {
        'poe-buecher': `SELECT
    m.medium_id,
    m.titel,
    s.regal_id,
    r.bezeichnung AS regal,
    ra.bezeichnung AS raum,
    s.ebene,
    s.position
FROM medium m
JOIN medium_person_role mpr
       ON  m.medium_id   = mpr.medium_id
       AND m.medientyp   = mpr.medientyp
JOIN person p
       ON  p.person_id   = mpr.person_id
JOIN role ro
       ON  ro.role_id    = mpr.role_id
LEFT JOIN standort s
       ON  s.medium_id   = m.medium_id
       AND s.medientyp   = m.medientyp
LEFT JOIN regal r
       ON  r.regal_id    = s.regal_id
LEFT JOIN raum ra
       ON  ra.raum_id    = r.raum_id
WHERE ro.role_name = 'Autor'
  AND p.nachname ILIKE '%Poe%'
  AND m.medientyp = 'Buch'
ORDER BY m.medium_id;`
    };

    // Event-Listener für empfohlene Queries
    document.querySelectorAll('.recommended-query').forEach(button => {
        button.addEventListener('click', function() {
            const queryId = this.dataset.query;
            if (recommendedQueries[queryId]) {
                editor.setValue(recommendedQueries[queryId]);
                editor.focus();
            }
        });
    });

    // Ausführen-Button
    document.getElementById('executeBtn').addEventListener('click', executeQuery);

    function executeQuery() {
        const query = editor.getValue();
        const startTime = performance.now();
        
        document.getElementById('loadingSpinner').classList.remove('d-none');
        document.getElementById('resultTable').classList.add('d-none');
        document.getElementById('errorMessage').classList.add('d-none');
        
        fetch('/api/execute_sql', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'query=' + encodeURIComponent(query)
        })
        .then(response => response.json())
        .then(data => {
            const endTime = performance.now();
            document.getElementById('loadingSpinner').classList.add('d-none');
            
            if (data.error) {
                showError(data.error);
                return;
            }
            
            showResults(data, endTime - startTime);
        })
        .catch(error => {
            document.getElementById('loadingSpinner').classList.add('d-none');
            showError('Fehler bei der Ausführung: ' + error);
        });
    }

    // Globale Sortierfunktion für die Tabelle
    let currentSortColumn = -1;
    let sortAscending = true;

    function sortTable(columnIndex) {
        const table = document.querySelector('table');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));

        // Ändere Sortierrichtung wenn gleiche Spalte
        if (currentSortColumn === columnIndex) {
            sortAscending = !sortAscending;
        } else {
            sortAscending = true;
            currentSortColumn = columnIndex;
        }

        // Update sort icons
        const headers = table.querySelectorAll('th');
        headers.forEach((header, index) => {
            const icon = header.querySelector('i');
            if (index === columnIndex) {
                icon.className = `bi ${sortAscending ? 'bi-sort-alpha-down' : 'bi-sort-alpha-up'} me-1`;
            } else {
                icon.className = icon.className.replace('bi-sort-alpha-up', 'bi-sort-alpha-down');
            }
        });

        rows.sort((a, b) => {
            const aValue = a.cells[columnIndex].textContent.trim();
            const bValue = b.cells[columnIndex].textContent.trim();

            // Spezielle Behandlung für Jahreszahlen
            if (columnIndex === 2) {
                const aYear = aValue === '-' ? 0 : parseInt(aValue);
                const bYear = bValue === '-' ? 0 : parseInt(bValue);
                return sortAscending ? aYear - bYear : bYear - aYear;
            }

            // Normale Textsorierung
            return sortAscending 
                ? aValue.localeCompare(bValue, 'de') 
                : bValue.localeCompare(aValue, 'de');
        });

        // Neue Reihenfolge anwenden
        rows.forEach(row => tbody.appendChild(row));
    }
});
