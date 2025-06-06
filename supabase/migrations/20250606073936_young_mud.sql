/*
  # Aggiorna email admin per Il Sorpasso

  1. Modifiche
    - Aggiorna tutte le policy RLS per usare ilsorpassodilorenzobasile@gmail.com invece di fracabu@gmail.com
    - Mantiene l'accesso admin per la gestione delle richieste di contatto

  2. Sicurezza
    - Mantiene RLS abilitato
    - Aggiorna le policy per il nuovo indirizzo email admin
    - Mantiene l'accesso pubblico per l'inserimento dei contatti
*/

-- Elimina le policy esistenti
DROP POLICY IF EXISTS "public_insert_contact_requests" ON contact_requests;
DROP POLICY IF EXISTS "admin_manage_contact_requests" ON contact_requests;

-- Assicura che RLS sia abilitato
ALTER TABLE contact_requests ENABLE ROW LEVEL SECURITY;

-- Crea policy per inserimento pubblico
CREATE POLICY "public_insert_contact_requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (
  name IS NOT NULL AND
  email IS NOT NULL AND
  message IS NOT NULL
);

-- Crea policy per gestione admin con nuovo indirizzo email
CREATE POLICY "admin_manage_contact_requests"
ON contact_requests
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'email' = 'ilsorpassodilorenzobasile@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'ilsorpassodilorenzobasile@gmail.com');