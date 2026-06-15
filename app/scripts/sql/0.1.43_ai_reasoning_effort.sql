-- v0.1.43 - Configuracion de reasoning_effort para endpoints IA OpenAI-compatible.

ALTER TABLE gestor_tickets.ai_llm_endpoints
    ADD COLUMN IF NOT EXISTS reasoning_effort text NOT NULL DEFAULT 'none';

DO $$
BEGIN
    ALTER TABLE gestor_tickets.ai_llm_endpoints
        ADD CONSTRAINT ai_llm_endpoints_reasoning_effort_check
        CHECK (reasoning_effort IN ('none', 'low', 'medium', 'high'));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
