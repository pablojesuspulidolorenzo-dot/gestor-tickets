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
    const aiForms = document.querySelectorAll(".ai-settings-form");

    const providerPresets = () => {
        document.querySelectorAll(".ai-provider-select").forEach((select) => {
            const applyPreset = (force = false) => {
                const option = select.selectedOptions[0];
                const form = select.closest("form");
                if (!option || !form) return;

                const baseUrl = form.querySelector(".ai-base-url");
                const modelsPath = form.querySelector(".ai-models-path");
                const chatPath = form.querySelector(".ai-chat-path");

                if (baseUrl && option.dataset.baseUrl && (force || !baseUrl.value.trim())) baseUrl.value = option.dataset.baseUrl;
                if (modelsPath && option.dataset.modelsPath && (force || !modelsPath.value.trim())) modelsPath.value = option.dataset.modelsPath;
                if (chatPath && option.dataset.chatPath && (force || !chatPath.value.trim())) chatPath.value = option.dataset.chatPath;
            };

            applyPreset(false);
            select.addEventListener("change", () => applyPreset(true));
        });
    };

    const selectedModel = (form) => {
        const manual = form.querySelector('input[name="manual_model"]')?.value.trim();
        const select = form.querySelector(".ai-model-select");
        return manual || select?.value || "";
    };

    const endpointPayload = (form, includeModel = false) => {
        const payload = {
            name: form.querySelector('input[name="name"]')?.value || "Prueba IA",
            provider_kind: form.querySelector('select[name="provider_kind"]')?.value || "generic",
            base_url: form.querySelector('input[name="base_url"]')?.value || "",
            models_endpoint_path: form.querySelector('input[name="models_endpoint_path"]')?.value || "/models",
            chat_endpoint_path: form.querySelector('input[name="chat_endpoint_path"]')?.value || "/chat/completions",
            api_key: form.querySelector('input[name="api_key"]')?.value || "",
            default_model: selectedModel(form) || null,
            is_active: true,
            is_default: false,
            timeout_seconds: Number(form.querySelector('input[name="timeout_seconds"]')?.value || 60),
            temperature: Number(form.querySelector('input[name="temperature"]')?.value || 0.2),
            top_p: Number(form.querySelector('input[name="top_p"]')?.value || 1),
            max_tokens: Number(form.querySelector('input[name="max_tokens"]')?.value || 1024),
            enable_thinking: Boolean(form.querySelector('input[name="enable_thinking"]')?.checked),
            daily_limit: null,
            free_quota_notes: form.querySelector('textarea[name="free_quota_notes"]')?.value || null,
            retry_policy_json: safeJson(form.querySelector('textarea[name="retry_policy_json"]')?.value, null),
            extra_headers_json: safeJson(form.querySelector('textarea[name="extra_headers_json"]')?.value, {}),
        };
        if (includeModel) payload.model_id = selectedModel(form) || null;
        return payload;
    };

    const safeJson = (value, fallback) => {
        const text = (value || "").trim();
        if (!text) return fallback;
        try { return JSON.parse(text); } catch { return fallback; }
    };

    const resultBox = (form) => form.querySelector(".ai-operation-result");

    const setResult = (form, message, kind = "info") => {
        const box = resultBox(form);
        if (!box) return;
        box.textContent = message;
        box.dataset.status = kind;
    };

    const setLoading = (button, loading) => {
        if (!button) return;
        if (loading) {
            button.dataset.originalHtml = button.innerHTML;
            button.disabled = true;
            button.innerHTML = button.dataset.loadingText || "Procesando...";
        } else {
            button.disabled = false;
            if (button.dataset.originalHtml) button.innerHTML = button.dataset.originalHtml;
            delete button.dataset.originalHtml;
        }
    };

    const updateModelMeta = (select) => {
        const selected = select?.selectedOptions?.[0];
        const meta = select?.closest("label")?.querySelector(".ai-model-meta");
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

    const populateModels = (form, models) => {
        const select = form.querySelector(".ai-model-select");
        const filter = form.querySelector(".ai-model-filter");
        if (!select) return;

        const current = select.value || select.dataset.selectedModel || "";
        select.innerHTML = "";
        models.forEach((model) => {
            const option = document.createElement("option");
            option.value = model.model_id;
            option.textContent = model.display_name && model.display_name !== model.model_id
                ? `${model.model_id} · ${model.display_name}`
                : model.model_id;
            option.dataset.ownedBy = model.owned_by || "";
            option.dataset.context = model.context_length || "";
            option.dataset.type = model.model_type || "";
            option.dataset.pricing = JSON.stringify(model.pricing_json || {});
            if (model.model_id === current) option.selected = true;
            select.appendChild(option);
        });
        if (!select.value && select.options.length) select.options[0].selected = true;
        if (filter) filter.value = "";
        updateModelMeta(select);
    };

    const filterModels = () => {
        document.querySelectorAll(".ai-model-filter").forEach((input) => {
            const select = document.getElementById(input.dataset.targetSelect);
            if (!select) return;
            input.addEventListener("input", () => {
                const query = input.value.trim().toLowerCase();
                Array.from(select.options).forEach((option) => {
                    const visible = option.textContent.toLowerCase().includes(query) || option.value.toLowerCase().includes(query);
                    option.hidden = !visible;
                });
            });
            select.addEventListener("change", () => updateModelMeta(select));
            updateModelMeta(select);
        });
    };

    const apiPost = async (url, payload) => {
        const response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        });
        const data = await response.json().catch(() => ({}));
        if (!response.ok) throw new Error(data.detail || "error_unknown");
        return data;
    };

    const wireAiActions = () => {
        aiForms.forEach((form) => {
            const modelsButton = form.querySelector(".ai-preview-models-button");
            const validateButton = form.querySelector(".ai-preview-validate-button");

            modelsButton?.addEventListener("click", async () => {
                const endpointId = modelsButton.dataset.endpointId;
                const apiKey = form.querySelector(".ai-api-key")?.value.trim();
                setLoading(modelsButton, true);
                setResult(form, "Obteniendo modelos...", "info");
                try {
                    let data;
                    if (endpointId && !apiKey) {
                        data = await apiPost(`/api/ai-settings/endpoints/${endpointId}/discover-models`, {});
                    } else {
                        data = await apiPost("/api/ai-settings/discover-models-preview", endpointPayload(form));
                    }
                    populateModels(form, data.models || []);
                    setResult(form, `Modelos obtenidos: ${(data.models || []).length}.`, "ok");
                } catch (error) {
                    setResult(form, `Error obteniendo modelos: ${error.message}`, "error");
                } finally {
                    setLoading(modelsButton, false);
                }
            });

            validateButton?.addEventListener("click", async () => {
                const endpointId = validateButton.dataset.endpointId;
                const apiKey = form.querySelector(".ai-api-key")?.value.trim();
                const model = selectedModel(form);
                if (!model) {
                    setResult(form, "Selecciona un modelo detectado o escribe un modelo manual.", "error");
                    return;
                }
                setLoading(validateButton, true);
                setResult(form, "Validando modelo...", "info");
                try {
                    let data;
                    if (endpointId && !apiKey) {
                        data = await apiPost(`/api/ai-settings/endpoints/${endpointId}/validate-model`, { model_id: model });
                    } else {
                        data = await apiPost("/api/ai-settings/validate-model-preview", endpointPayload(form, true));
                    }
                    const status = data.status === "ok" ? "Correcto" : data.status === "partial" ? "Advertencia" : "Error";
                    const details = [data.error_type, data.error_message, data.latency_ms ? `${data.latency_ms} ms` : null]
                        .filter(Boolean)
                        .join(" · ");
                    setResult(form, details ? `${status}: ${details}` : status, data.status === "ok" ? "ok" : "error");
                } catch (error) {
                    setResult(form, `Error validando modelo: ${error.message}`, "error");
                } finally {
                    setLoading(validateButton, false);
                }
            });
        });
    };

    providerPresets();
    filterModels();
    wireAiActions();
});
