document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM geladen, lade Ausleihen...');
    loadLoans();
    
    // Event Listener für Filter-Buttons
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            console.log('Filter geklickt:', this.dataset.status);
            filterLoans(this.dataset.status);
            filterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
        });
    });
});

async function loadLoans() {
    try {
        console.log('Lade Ausleihen...');
        const response = await fetch('/get_loans');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        console.log('Geladene Ausleihen:', data);
        
        if (data.success) {
            displayLoans(data.loans);
        } else {
            console.error('Fehler beim Laden der Ausleihen:', data.error);
            showError('Fehler beim Laden der Ausleihen: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler beim Laden der Ausleihen:', error);
        showError('Fehler beim Laden der Ausleihen: ' + error.message);
    }
}

function displayLoans(loans) {
    console.log('Zeige Ausleihen an:', loans);
    const tbody = document.querySelector('#loansTable tbody');
    if (!tbody) {
        console.error('tbody nicht gefunden!');
        return;
    }
    
    tbody.innerHTML = '';
    
    if (!loans || loans.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">Keine Ausleihen gefunden.</td></tr>';
        return;
    }
    
    loans.forEach(loan => {
        const row = document.createElement('tr');
        const status = getStatus(loan.rueckgabedatum);
        row.classList.add(status.class);
        
        row.innerHTML = `
            <td>${escapeHtml(loan.titel)}</td>
            <td>${escapeHtml(loan.medientyp)}</td>
            <td>${escapeHtml(loan.vorname)} ${escapeHtml(loan.nachname)}</td>
            <td>${formatDate(loan.ausleihdatum)}</td>
            <td>${formatDate(loan.rueckgabedatum)}</td>
            <td>${status.text}</td>
            <td>
                ${status.text !== 'Zurückgegeben' ? `
                    <button class="btn btn-success btn-sm" onclick="returnMedia('${loan.ausleihe_id}')">
                        <i class="bi bi-check-lg"></i> Zurückgeben
                    </button>
                ` : ''}
            </td>
        `;
        
        tbody.appendChild(row);
    });
}

function filterLoans(status) {
    console.log('Filtere nach Status:', status);
    const rows = document.querySelectorAll('#loansTable tbody tr');
    
    rows.forEach(row => {
        if (status === 'all' || row.classList.contains(status)) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

async function returnMedia(loanId) {
    try {
        const response = await fetch('/return_media', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                ausleihe_id: loanId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Aktualisiere die Anzeige
            loadLoans();
        } else {
            showError('Fehler bei der Rückgabe: ' + data.error);
        }
    } catch (error) {
        console.error('Fehler bei der Rückgabe:', error);
        showError('Fehler bei der Rückgabe: ' + error.message);
    }
}

// Hilfsfunktionen
function getStatus(returnDate) {
    const today = new Date();
    const returnDay = new Date(returnDate);
    
    if (returnDay < today) {
        return {
            text: 'Überfällig',
            class: 'overdue'
        };
    } else {
        return {
            text: 'Ausgeliehen',
            class: 'borrowed'
        };
    }
}

function formatDate(dateString) {
    const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
    return new Date(dateString).toLocaleDateString('de-DE', options);
}

function escapeHtml(unsafe) {
    if (!unsafe) return '';
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function showError(message) {
    // TODO: Implementiere eine schöne Fehleranzeige
    alert(message);
}
