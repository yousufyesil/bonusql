% rebase('base.tpl')
<div class="container-fluid">
    <div class="row my-4">
        <div class="col">
            <div class="card shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Personen</h5>
                    <div class="d-flex gap-2">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="bi bi-search"></i>
                            </span>
                            <input type="text" class="form-control border-start-0" id="searchInput" placeholder="Suche nach Namen...">
                        </div>
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addPersonModal">
                            <i class="bi bi-plus-lg"></i>
                            Neue Person
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Geburtstag</th>
                                    <th>Notizen</th>
                                </tr>
                            </thead>
                            <tbody>
                                % for person in persons:
                                <tr>
                                    <td>{{person['vorname']}} {{person['nachname']}}</td>
                                    <td>{{person['geburtstag'] if person['geburtstag'] else '-'}}</td>
                                    <td>{{person['notizen'] if person['notizen'] else '-'}}</td>
                                </tr>
                                % end
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal für neue Person -->
<div class="modal fade" id="addPersonModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Neue Person hinzufügen</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="addPersonForm">
                    <div class="mb-3">
                        <label for="vorname" class="form-label">Vorname</label>
                        <input type="text" class="form-control" id="vorname" required>
                    </div>
                    <div class="mb-3">
                        <label for="nachname" class="form-label">Nachname</label>
                        <input type="text" class="form-control" id="nachname" required>
                    </div>
                    <div class="mb-3">
                        <label for="geburtstag" class="form-label">Geburtstag</label>
                        <input type="date" class="form-control" id="geburtstag">
                    </div>
                    <div class="mb-3">
                        <label for="notizen" class="form-label">Notizen</label>
                        <textarea class="form-control" id="notizen" rows="3"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Abbrechen</button>
                <button type="button" class="btn btn-primary" onclick="addPerson()">Speichern</button>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('searchInput').addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase();
    const rows = document.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
        const name = row.cells[0].textContent.toLowerCase();
        row.style.display = name.includes(searchTerm) ? '' : 'none';
    });
});

async function addPerson() {
    const formData = {
        vorname: document.getElementById('vorname').value,
        nachname: document.getElementById('nachname').value,
        geburtstag: document.getElementById('geburtstag').value,
        notizen: document.getElementById('notizen').value
    };

    try {
        const response = await fetch('/add_person', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        const result = await response.json();
        if (result.success) {
            location.reload();
        } else {
            alert('Fehler beim Speichern: ' + result.error);
        }
    } catch (error) {
        alert('Fehler beim Speichern: ' + error);
    }
}
</script>
