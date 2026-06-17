console.log("Gestor Tickets: frontend cargado correctamente.");

document.addEventListener("DOMContentLoaded", () => {
    document.body.addEventListener("htmx:beforeRequest", (event) => {
        const elt = event.detail.elt;
        if (!elt || !elt.dataset || !elt.dataset.loadingText) return;
        if (!elt.dataset.originalHtml) elt.dataset.originalHtml = elt.innerHTML;
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
    if (!aiForms.length) return;

    const safeJson = (value, fallback) => {
        const text = (value || "").trim();
        if (!text) return fallback;
        try { return JSON.parse(text); } catch { return fallback; }
    };

    const setLoading = (button, loading) => {
        if (!button) return;
        if (loading) {
            button.dataset.originalHtml = button.innerHTML;
            button.disabled = true;
            button.innerHTML = button.dataset.loadingText || "Procesando...";
        } else {
            button.disabled = button.dataset.keepDisabled === "true";
            if (button.dataset.originalHtml) button.innerHTML = button.dataset.originalHtml;
            delete button.dataset.originalHtml;
        }
    };

    const setResult = (form, message, kind = "info") => {
        const box = form.querySelector(".ai-operation-result");
        if (!box) return;
        box.textContent = message;
        box.dataset.status = kind;
    };

    const setActiveTab = (form, phase) => {
        const target = String(phase);
        form.querySelectorAll("[data-ai-tab-panel]").forEach((section) => {
            section.classList.toggle("is-visible", section.dataset.aiTabPanel === target);
        });
        form.querySelectorAll(".ai-tab-button").forEach((button) => {
            const active = button.dataset.aiTab === target;
            button.classList.toggle("is-active", active);
            button.setAttribute("aria-selected", active ? "true" : "false");
        });
    };

    const setTabEnabled = (form, phase, enabled) => {
        const button = form.querySelector(`.ai-tab-button[data-ai-tab="${phase}"]`);
        if (button) button.disabled = !enabled;
    };

    const syncSaveButton = (form) => {
        const btn = form.querySelector("[data-ai-save-button]");
        if (!btn) return;
        btn.disabled = form.dataset.modelValidated !== "true";
    };

    const requireConnectionValidation = (form) => {
        form.dataset.connectionOk = "false";
        form.dataset.modelValidated = "false";
        setTabEnabled(form, 2, false);
        setTabEnabled(form, 3, false);
        setActiveTab(form, 1);
        syncSaveButton(form);
    };

    const selectedModel = (form) => {
        const manual = form.querySelector(".ai-manual-model")?.value.trim();
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
            api_key: form.querySelector(".ai-api-key")?.value || "",
            default_model: selectedModel(form) || null,
            is_active: Boolean(form.querySelector('input[name="is_active"]')?.checked),
            is_default: Boolean(form.querySelector('input[name="is_default"]')?.checked),
            timeout_seconds: Number(form.querySelector('input[name="timeout_seconds"]')?.value || 60),
            temperature: Number(form.querySelector('input[name="temperature"]')?.value || 0.2),
            top_p: Number(form.querySelector('input[name="top_p"]')?.value || 1),
            max_tokens: Number(form.querySelector('input[name="max_tokens"]')?.value || 32000),
            enable_thinking: Boolean(form.querySelector('input[name="enable_thinking"]')?.checked),
            reasoning_effort: form.querySelector('select[name="reasoning_effort"]')?.value || "none",
            daily_limit: Number(form.querySelector('input[name="daily_limit"]')?.value || 0) || null,
            free_quota_notes: form.querySelector('textarea[name="free_quota_notes"]')?.value || null,
            retry_policy_json: safeJson(form.querySelector('textarea[name="retry_policy_json"]')?.value, null),
            extra_headers_json: safeJson(form.querySelector('textarea[name="extra_headers_json"]')?.value, {}),
        };
        if (includeModel) payload.model_id = selectedModel(form) || null;
        return payload;
    };

    const apiPost = async (url, payload) => {
        const response = await fetch(url, {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify(payload)});
        const data = await response.json().catch(() => ({}));
        if (!response.ok) throw new Error(data.detail || "error_unknown");
        return data;
    };

    const toggleReasoningFields = (form) => {
        const provider = form.querySelector('select[name="provider_kind"]')?.value || "generic";
        const isGemini = provider === "gemini";
        form.querySelectorAll(".ai-google-reasoning-field").forEach((field) => { field.hidden = !isGemini; });
        form.querySelectorAll(".ai-enable-thinking-field").forEach((field) => { field.hidden = isGemini; });
    };

    const applyProviderPreset = (select, force = false) => {
        const option = select.selectedOptions[0];
        const form = select.closest("form");
        if (!option || !form) return;
        [[".ai-base-url", option.dataset.baseUrl], [".ai-models-path", option.dataset.modelsPath], [".ai-chat-path", option.dataset.chatPath]].forEach(([selector, value]) => {
            const input = form.querySelector(selector);
            if (input && value && (force || !input.value.trim())) input.value = value;
        });
    };

    const updateModelMeta = (form) => {
        const select = form.querySelector(".ai-model-select");
        const selected = select?.selectedOptions?.[0];
        const meta = form.querySelector(".ai-model-meta");
        if (!meta) return;
        if (!selected || !selected.value) {
            meta.textContent = "Selecciona un modelo para ver metadatos.";
            return;
        }
        const parts = [];
        if (selected.dataset.ownedBy) parts.push(`owner: ${selected.dataset.ownedBy}`);
        if (selected.dataset.context) parts.push(`contexto: ${selected.dataset.context}`);
        if (selected.dataset.type) parts.push(`tipo: ${selected.dataset.type}`);
        if (selected.dataset.free === "true") parts.push("posible gratuito");
        if (selected.dataset.pricing && selected.dataset.pricing !== "{}") parts.push(`pricing: ${selected.dataset.pricing}`);
        meta.textContent = parts.length ? parts.join(" · ") : "Sin metadatos adicionales.";
    };

    const refreshPhaseState = (form, options = {}) => {
        const hasModels = form.querySelectorAll(".ai-model-select option[value]:not([value=''])").length > 0;
        const hasModel = Boolean(selectedModel(form));
        const connectionOk = form.dataset.connectionOk === "true";
        setTabEnabled(form, 2, connectionOk);
        setTabEnabled(form, 3, connectionOk && hasModel);
        if (options.activateModelTab && connectionOk) setActiveTab(form, 2);
        if (options.activateConfigTab && connectionOk && hasModel) setActiveTab(form, 3);
        const empty = form.querySelector(".ai-config-model-empty");
        if (empty) empty.classList.toggle("is-hidden", hasModels);
        updateModelMeta(form);
        syncSaveButton(form);
    };

    const populateModels = (form, models) => {
        const select = form.querySelector(".ai-model-select");
        const filter = form.querySelector(".ai-model-filter");
        if (!select) return;
        const current = selectedModel(form) || select.dataset.selectedModel || "";
        select.innerHTML = '<option value="">Selecciona un modelo</option>';
        models.forEach((model) => {
            const option = document.createElement("option");
            option.value = model.model_id;
            option.textContent = model.display_name && model.display_name !== model.model_id ? `${model.model_id} · ${model.display_name}` : model.model_id;
            option.dataset.ownedBy = model.owned_by || "";
            option.dataset.context = model.context_length || "";
            option.dataset.type = model.model_type || "";
            option.dataset.free = model.is_free_hint ? "true" : "false";
            option.dataset.pricing = JSON.stringify(model.pricing_json || {});
            if (model.model_id === current) option.selected = true;
            select.appendChild(option);
        });
        if (!select.value && select.options.length > 1) select.options[1].selected = true;
        if (filter) filter.value = "";
        form.dataset.hasModels = models.length ? "true" : "false";
        // Re-fetching models forces model re-validation before saving
        form.dataset.modelValidated = "false";
        refreshPhaseState(form);
    };

    const renderValidation = (form, data, requestPayload) => {
        const box = form.querySelector("[data-ai-validation-result]");
        if (!box) return;
        const status = data.status === "ok" ? "OK" : data.status === "partial" ? "Advertencia" : "Error";
        const sent = {model: requestPayload.model_id || requestPayload.default_model, temperature: requestPayload.temperature, top_p: requestPayload.top_p, max_tokens: requestPayload.max_tokens, timeout_seconds: requestPayload.timeout_seconds, enable_thinking: requestPayload.enable_thinking, reasoning_effort: requestPayload.reasoning_effort, authorization: "Bearer ***redacted***", messages: "[technical validation prompt only]"};
        box.innerHTML = `<strong>${status}</strong><div>HTTP: ${data.http_status ?? "-"} · Latencia: ${data.latency_ms ?? "-"} ms · JSON estricto: ${data.strict_json_ok ? "sí" : "no"} · Thinking: ${data.thinking_detected ? "sí" : "no"}</div>${data.error_type ? `<div>Error: ${data.error_type}</div>` : ""}${data.error_message ? `<div>${data.error_message}</div>` : ""}<pre>Payload seguro:\n${JSON.stringify(sent, null, 2)}</pre>${data.response_text_preview ? `<pre>Respuesta preview:\n${data.response_text_preview}</pre>` : ""}`;
    };

    aiForms.forEach((form) => {
        form.querySelectorAll(".ai-provider-select").forEach((select) => {
            applyProviderPreset(select, false);
            toggleReasoningFields(form);
            select.addEventListener("change", () => { applyProviderPreset(select, true); toggleReasoningFields(form); });
        });
        form.querySelector(".ai-model-filter")?.addEventListener("input", (event) => {
            const select = form.querySelector(".ai-model-select");
            const query = event.target.value.trim().toLowerCase();
            if (!select) return;
            Array.from(select.options).forEach((option) => {
                option.hidden = Boolean(option.value) && !option.textContent.toLowerCase().includes(query) && !option.value.toLowerCase().includes(query);
            });
        });
        form.querySelectorAll(".ai-tab-button").forEach((button) => {
            button.addEventListener("click", () => {
                if (!button.disabled) setActiveTab(form, button.dataset.aiTab || "1");
            });
        });

        const validateKeyButton = form.querySelector(".ai-validate-key-button");
        const apiKeyInput = form.querySelector(".ai-api-key");
        const syncValidateKeyButton = () => {
            if (!validateKeyButton) return;
            delete validateKeyButton.dataset.keepDisabled;
            validateKeyButton.disabled = !(apiKeyInput?.value.trim());
        };
        syncValidateKeyButton();
        apiKeyInput?.addEventListener("input", () => {
            syncValidateKeyButton();
            requireConnectionValidation(form);
        });

        const syncModelSelection = () => {
            // Changing model requires re-validation before saving
            form.dataset.modelValidated = "false";
            syncSaveButton(form);
            refreshPhaseState(form, {activateConfigTab: Boolean(selectedModel(form))});
        };
        form.querySelector(".ai-model-select")?.addEventListener("change", syncModelSelection);
        form.querySelector(".ai-manual-model")?.addEventListener("input", syncModelSelection);

        const discover = async (button, validateConnectionOnly = false) => {
            const endpointId = form.dataset.endpointId;
            const apiKey = form.querySelector(".ai-api-key")?.value.trim();
            setLoading(button, true);
            setResult(form, validateConnectionOnly ? "Validando API key..." : "Obteniendo modelos...", "info");
            try {
                let data;
                if (endpointId && !apiKey) data = await apiPost(`/api/ai-settings/endpoints/${endpointId}/discover-models`, {});
                else data = await apiPost("/api/ai-settings/discover-models-preview", endpointPayload(form));
                populateModels(form, data.models || []);
                form.dataset.connectionOk = "true";
                if (validateConnectionOnly && button) {
                    button.dataset.keepDisabled = "true";
                    button.disabled = true;
                }
                setResult(form, `OK. Modelos obtenidos: ${(data.models || []).length}.`, "ok");
                refreshPhaseState(form, {activateModelTab: true});
            } catch (error) {
                form.dataset.connectionOk = "false";
                setResult(form, `Error: ${error.message}`, "error");
                refreshPhaseState(form);
            } finally {
                setLoading(button, false);
            }
        };

        form.querySelector(".ai-validate-key-button")?.addEventListener("click", (event) => discover(event.currentTarget, true));
        form.querySelector(".ai-preview-models-button")?.addEventListener("click", (event) => discover(event.currentTarget, false));
        form.querySelector(".ai-preview-validate-button")?.addEventListener("click", async (event) => {
            const button = event.currentTarget;
            const endpointId = form.dataset.endpointId;
            const apiKey = form.querySelector(".ai-api-key")?.value.trim();
            const model = selectedModel(form);
            if (!model) { setResult(form, "Selecciona un modelo detectado o escribe un modelo manual.", "error"); return; }
            const payload = endpointPayload(form, true);
            setLoading(button, true);
            setResult(form, "Validando modelo...", "info");
            try {
                let data;
                if (endpointId && !apiKey) data = await apiPost(`/api/ai-settings/endpoints/${endpointId}/validate-model`, {model_id: model});
                else data = await apiPost("/api/ai-settings/validate-model-preview", payload);
                renderValidation(form, data, payload);
                if (data.status === "ok") {
                    form.dataset.modelValidated = "true";
                    const activeCheckbox = form.querySelector('input[name="is_active"]');
                    if (activeCheckbox) {
                        activeCheckbox.disabled = false;
                        activeCheckbox.checked = true;
                    }
                }
                syncSaveButton(form);
                setResult(form, data.status === "ok" ? "Validación correcta." : `Validación con aviso: ${data.error_type || "revisar respuesta"}.`, data.status === "ok" ? "ok" : "error");
            } catch (error) {
                setResult(form, `Error validando modelo: ${error.message}`, "error");
            } finally {
                setLoading(button, false);
            }
        });

        // Restore state for already-configured endpoints
        if (form.dataset.hasApiKey === "true") {
            form.dataset.connectionOk = "true";
        }
        if (form.dataset.hasApiKey === "true" && form.dataset.hasDefaultModel === "true") {
            form.dataset.modelValidated = "true";
        }

        refreshPhaseState(form);
    });
});
