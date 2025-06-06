/*
  # Aggiungi utente admin Lorenzo

  1. Modifiche
    - Aggiorna le policy RLS per includere l'email di Lorenzo
    - Mantiene l'accesso per entrambi gli admin (fracabu@gmail.com e ilsorpassodilorenzobasile@gmail.com)

  2. Sicurezza
    - Mantiene RLS abilitato
    - Permette accesso admin a entrambi gli utenti
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

-- Crea policy per gestione admin con entrambi gli indirizzi email
CREATE POLICY "admin_manage_contact_requests"
ON contact_requests
FOR ALL
TO authenticated
USING (
  (auth.jwt() ->> 'email') IN (
    'fracabu@gmail.com',
    'ilsorpassodilorenzobasile@gmail.com'
  )
)
WITH CHECK (
  (auth.jwt() ->> 'email') IN (
    'fracabu@gmail.com',
    'ilsorpassodilorenzobasile@gmail.com'
  )
);