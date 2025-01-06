% rebase('templates/base.tpl', title='Medien Übersicht')
<div class="container">
    <div class="filters">
        <input type="text" id="searchInput" placeholder="Suche nach Titel oder Notizen..." class="search-input">
        <select id="typeFilter" class="filter-select">
            <option value="">Alle Medientypen</option>
        </select>
        <select id="conditionFilter" class="filter-select">
            <option value="">Alle Zustände</option>
        </select>
    </div>
    
    <div id="mediaGrid" class="media-grid">
        <!-- Media items will be loaded here -->
    </div>
</div>

<script src="/static/media.js"></script>
