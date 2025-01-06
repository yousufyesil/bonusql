% rebase('base.tpl')

<div class="container">
    <div class="alert alert-danger mt-4" role="alert">
        <h4 class="alert-heading">
            <i class="bi bi-exclamation-triangle-fill"></i>
            Ein Fehler ist aufgetreten
        </h4>
        <p>{{error}}</p>
        <hr>
        <p class="mb-0">
            <a href="javascript:history.back()" class="alert-link">
                <i class="bi bi-arrow-left"></i>
                Zurück zur vorherigen Seite
            </a>
        </p>
    </div>
</div>
