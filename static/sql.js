document.addEventListener('DOMContentLoaded', function() {
    const resultsDiv = document.getElementById('results');
    const loadingSpinner = document.getElementById('loadingSpinner');
    const executeBtn = document.getElementById('executeBtn');
    const resultCount = document.getElementById('resultCount');
    const executionTime = document.getElementById('executionTime');

    // Template Queries Event Handler
    document.querySelectorAll('.query-template').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const query = e.target.closest('.query-template').getAttribute('data-query');
            editor.setValue(query);
            editor.focus();
        });
    });

    // CodeMirror SQL-Editor initialisieren
    const editor = CodeMirror.fromTextArea(document.getElementById('sqlEditor'), {
        mode: 'text/x-sql',
        theme: 'dracula',
        lineNumbers: true,
        matchBrackets: true,
        autoCloseBrackets: true,
        indentUnit: 4,
        tabSize: 4,
        lineWrapping: true,
        extraKeys: {
            'Ctrl-Enter': executeQuery,
            'Cmd-Enter': executeQuery
        }
    });

    // Event Listener für den Execute-Button
    executeBtn.addEventListener('click', executeQuery);

    async function executeQuery() {
        const query = editor.getValue().trim();
        if (!query) {
            showError('Bitte geben Sie eine SQL-Abfrage ein.');
            return;
        }

        try {
            showLoading();
            const startTime = performance.now();

            const formData = new FormData();
            formData.append('query', query);

            const response = await fetch('/api/execute_sql', {
                method: 'POST',
                body: formData
            });

            const endTime = performance.now();
            const duration = ((endTime - startTime) / 1000).toFixed(3);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();

            if (data.error) {
                throw new Error(data.error);
            }

            displayResults(data, duration);
        } catch (error) {
            console.error('Error executing query:', error);
            showError(error.message);
        } finally {
            hideLoading();
        }
    }

    function showLoading() {
        loadingSpinner.classList.remove('d-none');
        resultsDiv.classList.add('d-none');
        resultCount.textContent = '';
        executionTime.textContent = '';
    }

    function hideLoading() {
        loadingSpinner.classList.add('d-none');
        resultsDiv.classList.remove('d-none');
    }

    function showError(message) {
        resultsDiv.innerHTML = `
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle me-2"></i>
                ${escapeHtml(message)}
            </div>
        `;
        resultCount.textContent = '';
        executionTime.textContent = '';
    }

    function displayResults(data, duration) {
        if (!data.results || data.results.length === 0) {
            resultsDiv.innerHTML = `
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    Die Abfrage hat keine Ergebnisse zurückgegeben.
                </div>
            `;
            updateStats(0, duration);
            return;
        }

        const tableHTML = createTableHTML(data.columns, data.results);
        resultsDiv.innerHTML = `
            <div class="table-responsive">
                ${tableHTML}
            </div>
        `;

        updateStats(data.rowCount, duration);
    }

    function createTableHTML(columns, results) {
        let html = `
            <table class="table">
                <thead>
                    <tr>
                        ${columns.map(col => `
                            <th>
                                <i class="bi bi-table me-1"></i>
                                ${escapeHtml(col)}
                            </th>
                        `).join('')}
                    </tr>
                </thead>
                <tbody>
        `;

        results.forEach(row => {
            html += '<tr class="search-result">';
            columns.forEach(col => {
                const value = row[col];
                html += `<td>${escapeHtml(value !== null ? value : 'NULL')}</td>`;
            });
            html += '</tr>';
        });

        html += `
                </tbody>
            </table>
        `;

        return html;
    }

    function updateStats(rowCount, duration) {
        resultCount.innerHTML = `
            <i class="bi bi-table me-1"></i>
            ${rowCount} ${rowCount === 1 ? 'Zeile' : 'Zeilen'}
        `;
        executionTime.innerHTML = `
            <i class="bi bi-clock-history me-1"></i>
            ${duration} Sekunden
        `;
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
});
