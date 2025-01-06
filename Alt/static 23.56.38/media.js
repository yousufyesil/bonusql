document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const typeFilter = document.getElementById('typeFilter');
    const conditionFilter = document.getElementById('conditionFilter');
    const mediaGrid = document.getElementById('mediaGrid');

    // Load filter options
    loadMediaTypes();
    loadConditions();

    // Load initial media data
    loadMedia();

    // Add event listeners for filters
    searchInput.addEventListener('input', debounce(loadMedia, 300));
    typeFilter.addEventListener('change', loadMedia);
    conditionFilter.addEventListener('change', loadMedia);

    async function loadMediaTypes() {
        try {
            const response = await fetch('/api/media/types');
            const data = await response.json();
            
            data.types.forEach(type => {
                const option = document.createElement('option');
                option.value = type;
                option.textContent = type;
                typeFilter.appendChild(option);
            });
        } catch (error) {
            console.error('Error loading media types:', error);
        }
    }

    async function loadConditions() {
        try {
            const response = await fetch('/api/media/conditions');
            const data = await response.json();
            
            data.conditions.forEach(condition => {
                const option = document.createElement('option');
                option.value = condition;
                option.textContent = condition;
                conditionFilter.appendChild(option);
            });
        } catch (error) {
            console.error('Error loading conditions:', error);
        }
    }

    async function loadMedia() {
        try {
            const searchTerm = searchInput.value;
            const type = typeFilter.value;
            const condition = conditionFilter.value;

            const params = new URLSearchParams();
            if (searchTerm) params.append('search', searchTerm);
            if (type) params.append('type', type);
            if (condition) params.append('condition', condition);

            const response = await fetch(`/api/media?${params.toString()}`);
            const data = await response.json();

            displayMedia(data.media);
        } catch (error) {
            console.error('Error loading media:', error);
            mediaGrid.innerHTML = '<p>Fehler beim Laden der Medien.</p>';
        }
    }

    function displayMedia(mediaItems) {
        mediaGrid.innerHTML = '';

        if (mediaItems.length === 0) {
            mediaGrid.innerHTML = '<p>Keine Medien gefunden.</p>';
            return;
        }

        mediaItems.forEach(item => {
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

    function debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
});
