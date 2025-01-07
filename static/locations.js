document.addEventListener('DOMContentLoaded', function() {
    loadLocationStats();
    loadLocationOverview();
    loadMediaTypeDistribution();
});

// Lade die Standort-Statistiken
async function loadLocationStats() {
    try {
        const response = await fetch('/api/location_overview');
        const data = await response.json();
        const locations = data.locations;

        // Berechne die Statistiken
        const totalLocations = locations.length;
        const totalMedia = locations.reduce((sum, loc) => sum + loc.anzahl_medien, 0);
        const avgMedia = totalMedia / totalLocations;

        // Aktualisiere die UI
        document.getElementById('totalLocations').textContent = totalLocations;
        document.getElementById('totalMedia').textContent = totalMedia;
        document.getElementById('avgMediaPerLocation').textContent = avgMedia.toFixed(1);
    } catch (error) {
        console.error('Error loading location stats:', error);
    }
}

// Lade die Standortübersicht
async function loadLocationOverview() {
    try {
        const response = await fetch('/api/location_overview');
        const data = await response.json();
        const locations = data.locations;
        
        const locationContainer = document.getElementById('locationContainer');
        locationContainer.innerHTML = '';
        
        locations.forEach(location => {
            const card = document.createElement('div');
            card.className = 'col-md-4 mb-4';
            card.innerHTML = `
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="bi bi-geo-alt me-2"></i>${location.standort_name}
                        </h5>
                        <h6 class="card-subtitle mb-2 text-muted">
                            <i class="bi bi-door-open me-1"></i>Raum: ${location.raum || 'Nicht angegeben'}
                        </h6>
                        <div class="mt-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span>Anzahl Medien:</span>
                                <span class="badge bg-primary">${location.anzahl_medien}</span>
                            </div>
                            ${location.medientypen.length > 0 ? `
                                <div class="mt-3">
                                    <small class="text-muted">Medientypen:</small>
                                    <div class="mt-1">
                                        ${location.medientypen.map(type => 
                                            `<span class="badge bg-secondary me-1">${type}</span>`
                                        ).join('')}
                                    </div>
                                </div>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `;
            locationContainer.appendChild(card);
        });
    } catch (error) {
        console.error('Error loading location overview:', error);
    }
}

// Lade die Medientypen-Verteilung
async function loadMediaTypeDistribution() {
    try {
        const response = await fetch('/api/location_overview');
        const data = await response.json();
        const locations = data.locations;
        
        const table = document.getElementById('mediaTypeDistribution');
        const tbody = table.querySelector('tbody');
        tbody.innerHTML = '';
        
        locations.forEach(location => {
            const types = location.medientypen;
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${location.standort_name}</td>
                <td>${types.includes('Buch') ? '✓' : '-'}</td>
                <td>${types.includes('DVD') ? '✓' : '-'}</td>
                <td>${types.includes('CD') ? '✓' : '-'}</td>
                <td>${types.includes('Noten') ? '✓' : '-'}</td>
                <td>${types.includes('Sonstiges') ? '✓' : '-'}</td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error('Error loading media type distribution:', error);
    }
}
