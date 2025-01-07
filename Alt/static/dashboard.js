document.addEventListener('DOMContentLoaded', function() {
    loadDashboardData();
    loadLocationDashboard();
});

async function loadDashboardData() {
    try {
        const response = await fetch('/api/lending_stats');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        
        updateStatistics(data.stats);
        updateCurrentLendings(data.current_lendings);
        updateTopBorrowers(data.top_borrowers);
        updateTopMedia(data.top_media);
    } catch (error) {
        console.error('Error loading dashboard data:', error);
        showError(error.message);
    }
}

function updateStatistics(stats) {
    document.getElementById('totalLendings').textContent = stats.gesamt_ausleihen;
    document.getElementById('currentLendings').textContent = stats.aktuelle_ausleihen;
    document.getElementById('overdueLendings').textContent = stats.ueberfaellige_ausleihen;
    document.getElementById('avgLendingDuration').textContent = `${stats.durchschnittliche_ausleihdauer} Tage`;
}

function updateCurrentLendings(lendings) {
    const tbody = document.querySelector('#currentLendingsTable tbody');
    tbody.innerHTML = '';

    lendings.forEach(lending => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>
                <strong>${escapeHtml(lending.titel)}</strong>
            </td>
            <td>${escapeHtml(lending.ausgeliehen_an)}</td>
            <td>${escapeHtml(lending.ausleihdatum)}</td>
            <td>
                <span class="badge ${lending.ueberfaellig ? 'bg-danger' : 'bg-success'}">
                    ${lending.ueberfaellig ? 'Überfällig' : 'Aktiv'}
                </span>
            </td>
        `;
        tbody.appendChild(tr);
    });

    if (lendings.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="4" class="text-center">
                    <i class="bi bi-info-circle me-2"></i>Keine aktuellen Ausleihen
                </td>
            </tr>
        `;
    }
}

function updateTopBorrowers(borrowers) {
    const tbody = document.querySelector('#topBorrowersTable tbody');
    tbody.innerHTML = '';

    borrowers.forEach((borrower, index) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>
                <i class="bi bi-trophy-fill me-2 text-warning"></i>
                ${escapeHtml(borrower.name)}
            </td>
            <td>
                <span class="badge bg-primary">
                    ${borrower.anzahl_ausleihen}
                </span>
            </td>
        `;
        tbody.appendChild(tr);
    });

    if (borrowers.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="2" class="text-center">
                    <i class="bi bi-info-circle me-2"></i>Keine Daten verfügbar
                </td>
            </tr>
        `;
    }
}

function updateTopMedia(media) {
    const tbody = document.querySelector('#topMediaTable tbody');
    tbody.innerHTML = '';

    media.forEach((item, index) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>
                <i class="bi bi-trophy-fill me-2 text-warning"></i>
                ${escapeHtml(item.titel)}
            </td>
            <td>
                <span class="badge bg-primary">
                    ${item.anzahl_ausleihen}
                </span>
            </td>
        `;
        tbody.appendChild(tr);
    });

    if (media.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="2" class="text-center">
                    <i class="bi bi-info-circle me-2"></i>Keine Daten verfügbar
                </td>
            </tr>
        `;
    }
}

function showError(message) {
    // Füge eine Fehlermeldung am Anfang der Seite ein
    const container = document.querySelector('.container');
    const errorDiv = document.createElement('div');
    errorDiv.className = 'alert alert-danger mt-4';
    errorDiv.innerHTML = `
        <i class="bi bi-exclamation-triangle me-2"></i>
        ${escapeHtml(message)}
    `;
    container.insertBefore(errorDiv, container.firstChild);
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

// Standort Dashboard
function loadLocationDashboard() {
    fetch('/api/location_overview')
        .then(response => response.json())
        .then(data => {
            const locations = data.locations;
            
            // Erstelle die Standortkarten
            const locationContainer = document.getElementById('locationContainer');
            locationContainer.innerHTML = '';
            
            locations.forEach(location => {
                const card = document.createElement('div');
                card.className = 'col-md-4 mb-4';
                card.innerHTML = `
                    <div class="card h-100">
                        <div class="card-body">
                            <h5 class="card-title">${location.standort_name}</h5>
                            <h6 class="card-subtitle mb-2 text-muted">Raum: ${location.raum || 'Nicht angegeben'}</h6>
                            <p class="card-text">
                                <strong>Anzahl Medien:</strong> ${location.anzahl_medien}<br>
                                <strong>Medientypen:</strong><br>
                                ${location.medientypen.join(', ') || 'Keine Medien'}
                            </p>
                        </div>
                    </div>
                `;
                locationContainer.appendChild(card);
            });
        })
        .catch(error => console.error('Error:', error));
}
