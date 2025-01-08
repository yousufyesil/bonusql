<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SQL Query Tool - Medien Verwaltung</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/theme/dracula.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/styles.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="/">
                <i class="bi bi-collection-play me-2"></i>
                Medien Verwaltung
            </a>
            <div class="navbar-nav">
                <a class="nav-link" href="/">
                    <i class="bi bi-house-door me-1"></i>Home
                </a>
                <a class="nav-link active" href="/sql">
                    <i class="bi bi-code-square me-1"></i>SQL
                </a>
                 <a class="nav-link" href="/dashboard">
                    <i class="bi bi-graph-up me-1"></i>Dashboard
                </a>
               <a class="nav-link" href="/locations">
                    <i class="bi bi-graph-up me-1"></i>Locations
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="search-card">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">SQL Query Tool</h5>
                <button id="executeBtn" class="btn btn-primary">
                    <i class="bi bi-play-fill me-1"></i>Ausführen
                </button>
            </div>
            <textarea id="sqlEditor" class="form-control" rows="5">
SELECT * FROM medium LIMIT 10;
            </textarea>
            
            <!-- Beliebte Anfragen Section -->
            <div class="card mb-4">
                <div class="card-header">
                    <h6 class="mb-0">
                        <i class="bi bi-lightning-fill me-2"></i>Beliebte Anfragen
                    </h6>
                </div>
                <div class="card-body">
                    <div class="list-group list-group-flush">
                        <a href="#" class="list-group-item list-group-item-action query-template" data-query="SELECT
    m.medium_id,
    m.titel,
    s.regal_id,
    r.bezeichnung AS regal,
    ra.bezeichnung AS raum,
    s.ebene,
    s.position
FROM medium m
JOIN medium_person_role mpr 
       ON  m.medium_id   = mpr.medium_id
       AND m.medientyp   = mpr.medientyp
JOIN person p 
       ON  p.person_id   = mpr.person_id
JOIN role ro 
       ON  ro.role_id    = mpr.role_id
LEFT JOIN standort s 
       ON  s.medium_id   = m.medium_id
       AND s.medientyp   = m.medientyp
LEFT JOIN regal r 
       ON  r.regal_id    = s.regal_id
LEFT JOIN raum ra
       ON  ra.raum_id    = r.raum_id
WHERE ro.role_name = 'Autor'
  AND p.nachname ILIKE '%Poe%'
  AND m.medientyp = 'Buch'
ORDER BY m.medium_id;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>Anfrage A</strong>
                                    <div class="text-muted small">Finde alle Bücher von Poe mit Standortinformationen</div>
                                </div>
                                <i class="bi bi-chevron-right text-muted"></i>
                            </div>
                        </a>
                        <a href="#" class="list-group-item list-group-item-action query-template" data-query="SELECT
    m.medium_id,
    m.titel,
    m.erscheinungsjahr,
    s.regal_id,
    r.bezeichnung AS regal,
    ra.bezeichnung AS raum,
    s.ebene,
    s.position
FROM medium m
JOIN buch b
       ON  b.medium_id   = m.medium_id
       AND b.medientyp   = m.medientyp
LEFT JOIN standort s
       ON  s.medium_id   = m.medium_id
       AND s.medientyp   = m.medientyp
LEFT JOIN regal r
       ON  r.regal_id    = s.regal_id
LEFT JOIN raum ra
       ON  ra.raum_id    = r.raum_id
WHERE m.medientyp = 'Noten'
  AND m.titel ILIKE '%Fantaisie-Impromptu%'
ORDER BY m.medium_id;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>Anfrage B</strong>
                                    <div class="text-muted small">Finde alle Noten mit dem Titel 'Fantaisie-Impromptu'</div>
                                </div>
                                <i class="bi bi-chevron-right text-muted"></i>
                            </div>
                        </a>
                        <a href="#" class="list-group-item list-group-item-action query-template" data-query="SELECT
    sb.sammelband_id,
    sb.titel    AS sammelband_titel,
    bs.position AS band_position,
    m.medium_id,
    m.titel     AS buch_titel,
    s.position  AS standort_pos,
    r.bezeichnung AS regal,
    ra.bezeichnung AS raum
FROM sammelband sb
JOIN buch_sammelband bs
       ON  bs.sammelband_id = sb.sammelband_id
JOIN medium m
       ON  m.medium_id      = bs.medium_id
       AND m.medientyp      = 'Buch'
LEFT JOIN standort s
       ON  s.medium_id      = m.medium_id
       AND s.medientyp      = m.medientyp
LEFT JOIN regal r
       ON  r.regal_id       = s.regal_id
LEFT JOIN raum ra
       ON  ra.raum_id       = r.raum_id
ORDER BY sb.sammelband_id, bs.position;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>Anfrage C</strong>
                                    <div class="text-muted small">Finde alle Bücher in Sammelbänden mit Standortinformationen</div>
                                </div>
                                <i class="bi bi-chevron-right text-muted"></i>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-between align-items-center mb-2">
                <div id="resultCount" class="text-muted"></div>
                <div id="executionTime" class="text-muted"></div>
            </div>
        </div>

        <div id="loadingSpinner" class="spinner d-none"></div>
        <div id="results"></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/mode/sql/sql.min.js"></script>
    <script src="/static/sql.js"></script>
</body>
</html>
