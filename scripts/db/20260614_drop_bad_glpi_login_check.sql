-- Corrige una restricción de diseño incorrecta en collaborative_accounts.
--
-- La cuenta colaborativa y el login GLPI NO tienen por qué coincidir:
--   email de buzón colaborativo: sistemas-tic@gestor-tickets.es
--   login GLPI asociado:         sistemas-tic
--
-- Esta migración es idempotente.

ALTER TABLE gestor_tickets.collaborative_accounts
DROP CONSTRAINT IF EXISTS collaborative_account_glpi_login_matches_email;
