console.log("Gestor Tickets: frontend cargado correctamente.");

document.addEventListener("DOMContentLoaded", () => {
    document.body.addEventListener("htmx:beforeRequest", (event) => {
        const elt = event.detail.elt;
        if (!elt || !elt.dataset || !elt.dataset.loadingText) return;

        if (!elt.dataset.originalHtml) {
            elt.dataset.originalHtml = elt.innerHTML;
        }

        elt.disabled = true;
        elt.classList.add("is-loading");
        elt.innerHTML = elt.dataset.loadingText;
    });

    document.body.addEventListener("htmx:afterRequest", (event) => {
        const elt = event.detail.elt;
        if (!elt || !elt.dataset || !elt.dataset.originalHtml) return;

        elt.innerHTML = elt.dataset.originalHtml;
        delete elt.dataset.originalHtml;
        elt.disabled = false;
        elt.classList.remove("is-loading");
    });
});
