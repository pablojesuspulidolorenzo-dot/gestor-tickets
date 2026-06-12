\connect gestor_tickets;

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS age;

LOAD 'age';
SET search_path = ag_catalog, "$user", public;

DO $$
BEGIN
    PERFORM create_graph('gestor_tickets_graph');
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'No se pudo crear el grafo gestor_tickets_graph o ya existe: %', SQLERRM;
END $$;
