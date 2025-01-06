document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM geladen, lade Medien...');
    loadMedia();
    
    // Event Listener für das Suchfeld
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        let timeout = null;
        searchInput.addEventListener('input', function() {
            clearTimeout(timeout);
            timeout = setTimeout(() => {
                const query = this.value.trim();
                if (query) {
                    searchMedia(query);
                } else {
                    loadMedia();
                }
            }, 300);
        });
    }
});

async function loadMedia() {
    try {
        console.log('Lade Medien...');
        const response = await fetch('/api/media');
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        displayMedia(data.media);
    } catch (error) {
        console.error('Fehler beim Laden der Medien:', error);
        showError('Fehler beim Laden der Medien: ' + error.message);
    }
}

async function searchMedia(query) {
    try {
        const response = await fetch(`/api/media?search=${encodeURIComponent(query)}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        displayMedia(data.media);
    } catch (error) {
        console.error('Fehler bei der Suche:', error);
        showError('Fehler bei der Suche: ' + error.message);
    }
}

function displayMedia(media) {
    const mediaGrid = document.getElementById('mediaGrid');
    
    if (!mediaGrid) {
        console.error('Media grid nicht gefunden');
        return;
    }
    
    if (!media || media.length === 0) {
        mediaGrid.innerHTML = '<p class="no-results">Keine Medien gefunden.</p>';
        return;
    }

    mediaGrid.innerHTML = '';
    media.forEach(item => {
        const card = document.createElement('div');
        card.className = 'media-card';
        card.innerHTML = `
            <h3>${escapeHtml(item.title)}</h3>
            <div class="media-info">Typ: ${escapeHtml(item.type)}</div>
            <div class="media-info">Jahr: ${escapeHtml(item.year.toString())}</div>
            <div class="media-info">Medium: ${escapeHtml(item.medium)}</div>
            <div class="media-info">Zustand: ${escapeHtml(item.condition)}</div>
            ${item.notes ? `<div class="media-notes">${escapeHtml(item.notes)}</div>` : ''}
        `;
        mediaGrid.appendChild(card);
    });
}

function escapeHtml(unsafe) {
    return unsafe
        .toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function showError(message) {
    console.error(message);
    const mediaGrid = document.getElementById('mediaGrid');
    if (mediaGrid) {
        mediaGrid.innerHTML = `<p class="error-message">${escapeHtml(message)}</p>`;
    }
}
