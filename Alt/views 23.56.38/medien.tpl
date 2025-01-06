% rebase('base.tpl')
<div class="card">
    <div class="card-header">
        <h2 class="card-title">Medien</h2>
        <div class="header-actions">
            <input type="text" class="search-input" placeholder="Suche...">
        </div>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Titel</th>
                        <th>Typ</th>
                        <th>Jahr</th>
                        <th>Datenträger</th>
                        <th>Zustand</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    % for medium in media:
                    <tr>
                        <td>{{medium['titel']}}</td>
                        <td>{{medium['medientyp']}}</td>
                        <td>{{medium['erscheinungsjahr'] if medium['erscheinungsjahr'] else '-'}}</td>
                        <td>{{medium['datentraeger'] if medium['datentraeger'] else '-'}}</td>
                        <td>{{medium['zustand']}}</td>
                        <td>
                            % if medium['ist_ausgeliehen']:
                                <span class="badge bg-danger">Ausgeliehen</span>
                            % else:
                                <span class="badge bg-success">Verfügbar</span>
                            % end
                        </td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
document.getElementById('searchInput').addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase();
    const rows = document.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
        const title = row.cells[0].textContent.toLowerCase();
        row.style.display = title.includes(searchTerm) ? '' : 'none';
    });
});
</script>
