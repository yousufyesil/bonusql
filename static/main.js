// Globale Variablen
let currentResults = [];
let currentFilter = 'all';

// Event-Listener
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM geladen, lade Medien...');
    loadAllMedia();
    
    // Event Listener für Filter-Buttons
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            console.log('Filter geklickt:', this.dataset.type);
            currentFilter = this.dataset.type;
            filterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            displayResults(currentResults);
        });
    });

    // Event Listener für das Suchfeld
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            searchBooks();
        });
    }
});

// Medien laden
async function loadAllMedia() {
    try {
        console.log('Starte Laden der Medien...');
        const response = await fetch('/medien');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        console.log('Geladene Medien:', data);
        
        if (data.success) {
            currentResults = data.medien;
            displayResults(currentResults);
        } else {
            console.error('Fehler beim Laden der Medien:', data.error);
            showError('Fehler beim Laden der Medien: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler beim Laden der Medien:', error);
        showError('Fehler beim Laden der Medien: ' + error.message);
    }
}

// Suche
async function searchBooks() {
    const query = document.getElementById('searchInput').value.trim();
    
    if (!query) {
        displayResults(currentResults);
        return;
    }
    
    try {
        const response = await fetch(`/search?q=${encodeURIComponent(query)}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        
        if (data.success) {
            currentResults = data.medien;
            displayResults(currentResults);
        } else {
            console.error('Fehler bei der Suche:', data.error);
            showError('Fehler bei der Suche: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler bei der Suche:', error);
        showError('Fehler bei der Suche: ' + error.message);
    }
}

// Ergebnisse anzeigen
function displayResults(results) {
    console.log('Zeige Ergebnisse an:', results);
    const resultsDiv = document.getElementById('results');
    
    if (!results || results.length === 0) {
        resultsDiv.innerHTML = '<p class="text-center">Keine Medien gefunden.</p>';
        return;
    }
    
    let html = '<div class="row row-cols-1 row-cols-md-3 g-4">';
    
    results.forEach(medium => {
        console.log('Verarbeite Medium:', medium);
        if (currentFilter !== 'all' && medium.medientyp !== currentFilter) {
            return;
        }
        
        html += `
            <div class="col">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="card-title">${escapeHtml(medium.titel)}</h5>
                        <p class="card-text">
                            <strong>Typ:</strong> ${escapeHtml(medium.medientyp)}<br>
                            ${medium.autor ? `<strong>Autor:</strong> ${escapeHtml(medium.autor)}<br>` : ''}
                            ${medium.erscheinungsjahr ? `<strong>Jahr:</strong> ${escapeHtml(medium.erscheinungsjahr.toString())}<br>` : ''}
                            ${medium.verlag ? `<strong>Verlag:</strong> ${escapeHtml(medium.verlag)}<br>` : ''}
                            ${medium.isbn ? `<strong>ISBN:</strong> ${escapeHtml(medium.isbn)}<br>` : ''}
                            ${medium.barcode ? `<strong>Barcode:</strong> ${escapeHtml(medium.barcode)}` : ''}
                        </p>
                    </div>
                    <div class="card-footer">
                        <button class="btn btn-primary btn-sm" onclick="showLendDialog('${medium.medium_id}', '${medium.medientyp}')">
                            <i class="bi bi-box-arrow-right"></i> Ausleihen
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
    
    html += '</div>';
    resultsDiv.innerHTML = html;
}

// Hilfsfunktionen
function escapeHtml(unsafe) {
    if (!unsafe) return '';
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function showLendDialog(mediumId, medientyp) {
    // Setze die Medium-ID und den Medientyp
    document.getElementById('lendMediumId').value = mediumId;
    document.getElementById('lendMedientyp').value = medientyp;
    
    // Lade die Ausleiher
    loadBorrowers();
    
    // Öffne den Modal-Dialog
    const lendDialog = new bootstrap.Modal(document.getElementById('lendDialog'));
    lendDialog.show();
}

// Ausleiher laden
async function loadBorrowers() {
    try {
        const response = await fetch('/get_borrowers');
        const data = await response.json();
        
        if (data.success) {
            const select = document.getElementById('borrowerSelect');
            select.innerHTML = '<option value="">Bitte wählen...</option>';
            
            data.borrowers.forEach(borrower => {
                const option = document.createElement('option');
                option.value = borrower.person_id;
                option.textContent = `${borrower.vorname} ${borrower.nachname}`;
                select.appendChild(option);
            });
        } else {
            console.error('Fehler beim Laden der Ausleiher:', data.error);
            showError('Fehler beim Laden der Ausleiher: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler beim Laden der Ausleiher:', error);
        showError('Fehler beim Laden der Ausleiher: ' + error.message);
    }
}

// Neuen Ausleiher Formular anzeigen
function showNewBorrowerForm() {
    const form = document.getElementById('newBorrowerForm');
    form.style.display = form.style.display === 'none' ? 'block' : 'none';
}

// Ausleihe verarbeiten
async function handleLend(event) {
    event.preventDefault();
    
    const mediumId = document.getElementById('lendMediumId').value;
    const medientyp = document.getElementById('lendMedientyp').value;
    const borrowerId = document.getElementById('borrowerSelect').value;
    const lendDate = document.getElementById('lendDate').value;
    const returnDate = document.getElementById('returnDate').value;
    
    // Prüfe, ob ein neuer Ausleiher hinzugefügt werden soll
    const newBorrowerForm = document.getElementById('newBorrowerForm');
    const isNewBorrower = newBorrowerForm.style.display === 'block';
    
    if (isNewBorrower) {
        // Validiere die Felder für den neuen Ausleiher
        const firstName = document.getElementById('borrowerFirstName').value;
        const lastName = document.getElementById('borrowerLastName').value;
        const email = document.getElementById('borrowerEmail').value;
        const phone = document.getElementById('borrowerPhone').value;
        
        if (!firstName || !lastName || !email) {
            showError('Bitte füllen Sie alle Pflichtfelder aus.');
            return;
        }
        
        try {
            // Füge den neuen Ausleiher hinzu
            const response = await fetch('/add_borrower', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    vorname: firstName,
                    nachname: lastName,
                    email: email,
                    telefon: phone
                })
            });
            
            const data = await response.json();
            
            if (!data.success) {
                showError('Fehler beim Hinzufügen des Ausleihers: ' + data.error);
                return;
            }
            
            // Verwende die ID des neu erstellten Ausleihers
            borrowerId = data.person_id;
        } catch (error) {
            console.error('Fehler beim Hinzufügen des Ausleihers:', error);
            showError('Fehler beim Hinzufügen des Ausleihers: ' + error.message);
            return;
        }
    } else if (!borrowerId) {
        showError('Bitte wählen Sie einen Ausleiher aus.');
        return;
    }
    
    if (!lendDate || !returnDate) {
        showError('Bitte wählen Sie Ausleih- und Rückgabedatum.');
        return;
    }
    
    try {
        const response = await fetch('/lend', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                medium_id: mediumId,
                medientyp: medientyp,
                person_id: borrowerId,
                ausleihdatum: lendDate,
                rueckgabedatum: returnDate
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Schließe den Modal-Dialog
            const lendDialog = bootstrap.Modal.getInstance(document.getElementById('lendDialog'));
            lendDialog.hide();
            
            // Zeige Erfolgsmeldung
            showError('Medium erfolgreich ausgeliehen.');
            
            // Aktualisiere die Anzeige
            loadAllMedia();
        } else {
            showError('Fehler beim Ausleihen: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler beim Ausleihen:', error);
        showError('Fehler beim Ausleihen: ' + error.message);
    }
}

function showError(message) {
    // TODO: Implementiere eine schöne Fehleranzeige
    alert(message);
}
