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


document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".ai-provider-select").forEach((select) => {
        select.addEventListener("change", () => {
            const option = select.selectedOptions[0];
            const form = select.closest("form");
            if (!option || !form) return;

            const baseUrl = form.querySelector(".ai-base-url");
            const modelsPath = form.querySelector(".ai-models-path");
            const chatPath = form.querySelector(".ai-chat-path");

            if (baseUrl && option.dataset.baseUrl) baseUrl.value = option.dataset.baseUrl;
            if (modelsPath && option.dataset.modelsPath) modelsPath.value = option.dataset.modelsPath;
            if (chatPath && option.dataset.chatPath) chatPath.value = option.dataset.chatPath;
        });
    });

    document.querySelectorAll(".ai-model-filter").forEach((input) => {
        const select = document.getElementById(input.dataset.targetSelect);
        if (!select) return;

        const updateMeta = () => {
            const selected = select.selectedOptions[0];
            const meta = select.closest("label")?.querySelector(".ai-model-meta");
            if (!meta || !selected) return;

            const parts = [];
            if (selected.dataset.ownedBy) parts.push(`owner: ${selected.dataset.ownedBy}`);
            if (selected.dataset.context) parts.push(`contexto: ${selected.dataset.context}`);
            if (selected.dataset.type) parts.push(`tipo: ${selected.dataset.type}`);
            if (selected.dataset.pricing && selected.dataset.pricing !== "{}") parts.push(`pricing: ${selected.dataset.pricing}`);
            meta.textContent = parts.length ? parts.join(" · ") : "Sin metadatos adicionales.";

            document.querySelectorAll(".ai-validate-model-id").forEach((hidden) => {
                hidden.value = selected.value || "";
            });
        };

        input.addEventListener("input", () => {
            const query = input.value.trim().toLowerCase();
            Array.from(select.options).forEach((option) => {
                const visible = option.textContent.toLowerCase().includes(query) || option.value.toLowerCase().includes(query);
                option.hidden = !visible;
            });
        });

        select.addEventListener("change", updateMeta);
        updateMeta();
    });
});
