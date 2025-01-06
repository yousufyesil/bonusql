// Suchfunktion
let searchTimeout;
document.getElementById('searchInput').addEventListener('input', function(e) {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        const searchTerm = e.target.value.trim();
        if (searchTerm.length > 0) {
            fetch(`/search_loans?q=${encodeURIComponent(searchTerm)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateLoansTable(data.loans);
                    } else {
                        console.log('Fehler bei der Suche:', data.error);
                    }
                })
                .catch(error => console.log('Fehler bei der Suche:', error));
        } else {
            loadLoans();
        }
    }, 300);
});

// Ausleihen laden
function loadLoans(filter = 'current') {
    fetch(`/get_loans?filter=${filter}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                updateLoansTable(data.loans);
            } else {
                console.error('Fehler beim Laden der Ausleihen:', data.error);
            }
        })
        .catch(error => console.error('Fehler beim Laden der Ausleihen:', error));
}

// Tabelle aktualisieren
function updateLoansTable(loans) {
    const tbody = document.getElementById('loansTableBody');
    tbody.innerHTML = '';
    
    loans.forEach(loan => {
        const tr = document.createElement('tr');
        if (!loan.rueckgabe_datum) {
            tr.classList.add('borrowed');
        }
        
        tr.innerHTML = `
            <td>${loan.titel}</td>
            <td>${loan.vorname} ${loan.nachname}</td>
            <td>${loan.medientyp}</td>
            <td>${loan.ausleih_datum}</td>
            <td>${loan.rueckgabe_datum || '-'}</td>
            <td>
                ${!loan.rueckgabe_datum ? `
                    <button class="btn btn-sm btn-outline-success" onclick="returnLoan('${loan.medium_id}', '${loan.medientyp}')">
                        <i class="bi bi-check-lg"></i> Rückgabe
                    </button>
                ` : ''}
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// Ausleihe zurückgeben
function returnLoan(mediumId, medientyp) {
    if (!confirm('Möchten Sie diese Ausleihe wirklich als zurückgegeben markieren?')) {
        return;
    }
    
    fetch('/return_loan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            medium_id: mediumId,
            medientyp: medientyp
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const activeFilter = document.querySelector('[data-filter].active').dataset.filter;
            loadLoans(activeFilter);
        } else {
            alert('Fehler beim Zurückgeben: ' + data.error);
        }
    })
    .catch(error => {
        console.error('Fehler beim Zurückgeben:', error);
        alert('Fehler beim Zurückgeben: ' + error);
    });
}

// Event Listener für Filter-Buttons
document.querySelectorAll('[data-filter]').forEach(button => {
    button.addEventListener('click', function() {
        document.querySelectorAll('[data-filter]').forEach(btn => btn.classList.remove('active'));
        this.classList.add('active');
        loadLoans(this.dataset.filter);
    });
});

// Event Listener für "Neue Ausleihe" Button
document.getElementById('saveLoanBtn').addEventListener('click', addLoan);
document.getElementById('saveBorrowerBtn').addEventListener('click', addBorrower);

function loadAvailableMedia() {
    fetch('/get_available_media')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const select = document.getElementById('mediumSelect');
                select.innerHTML = '<option value="">Bitte wählen...</option>';
                data.media.forEach(medium => {
                    const option = document.createElement('option');
                    option.value = JSON.stringify({ id: medium.medium_id, type: medium.medientyp });
                    option.textContent = `${medium.titel} (${medium.medientyp})`;
                    select.appendChild(option);
                });
            }
        })
        .catch(error => console.error('Fehler beim Laden der verfügbaren Medien:', error));
}

function loadBorrowers() {
    fetch('/get_borrowers')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const select = document.getElementById('personSelect');
                select.innerHTML = '<option value="">Bitte wählen...</option>';
                data.borrowers.forEach(borrower => {
                    const option = document.createElement('option');
                    option.value = borrower.person_id;
                    option.textContent = `${borrower.vorname} ${borrower.nachname}`;
                    select.appendChild(option);
                });
            }
        })
        .catch(error => console.error('Fehler beim Laden der Ausleiher:', error));
}

function addLoan() {
    const mediumSelect = document.getElementById('mediumSelect');
    const personSelect = document.getElementById('personSelect');
    
    if (!mediumSelect.value || !personSelect.value) {
        alert('Bitte alle Pflichtfelder ausfüllen');
        return;
    }
    
    const mediumData = JSON.parse(mediumSelect.value);
    
    const data = {
        medium_id: mediumData.id,
        medientyp: mediumData.type,
        person_id: personSelect.value,
        ausleih_datum: new Date().toISOString().split('T')[0]
    };
    
    fetch('/add_loan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('addLoanModal')).hide();
            loadLoans();
            loadAvailableMedia();
        } else {
            alert('Fehler beim Erstellen der Ausleihe: ' + data.error);
        }
    })
    .catch(error => {
        console.error('Fehler beim Erstellen der Ausleihe:', error);
        alert('Fehler beim Erstellen der Ausleihe: ' + error);
    });
}

function addBorrower() {
    const data = {
        vorname: document.getElementById('borrowerFirstName').value,
        nachname: document.getElementById('borrowerLastName').value,
        adresse: document.getElementById('borrowerAddress').value,
        telefon: document.getElementById('borrowerPhone').value
    };
    
    fetch('/add_borrower', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('addBorrowerModal')).hide();
            loadBorrowers();
            // Person in der Ausleihe vorauswählen
            document.getElementById('personSelect').value = data.person_id;
        } else {
            alert('Fehler beim Erstellen der Person: ' + data.error);
        }
    })
    .catch(error => {
        console.error('Fehler beim Erstellen der Person:', error);
        alert('Fehler beim Erstellen der Person: ' + error);
    });
}

document.addEventListener('DOMContentLoaded', function() {
    loadLoans('current');
    loadAvailableMedia();
    loadBorrowers();
});
