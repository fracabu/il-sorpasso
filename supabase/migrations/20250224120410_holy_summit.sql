/*
  # Semplificazione del sistema di contatti

  1. Modifiche
    - Rimozione del trigger di notifica email
    - Rimozione della colonna webhook_url
    - Mantenimento delle policy di sicurezza per l'area admin

  2. Sicurezza
    - Mantenute le policy per l'accesso admin
    - Mantenuta la policy per l'inserimento pubblico dei contatti
*/

-- Rimuovi il trigger esistente se presente
DROP TRIGGER IF EXISTS contact_request_notification ON contact_requests;

-- Rimuovi la funzione esistente se presente
DROP FUNCTION IF EXISTS notify_admin_contact_request();
DROP FUNCTION IF EXISTS handle_contact_request();

-- Rimuovi la colonna webhook_url se presente
ALTER TABLE contact_requests 
DROP COLUMN IF EXISTS webhook_url;

-- Aggiorna le policy per l'accesso admin
DO $$ 
BEGIN
  -- Aggiorna la policy di lettura
  ALTER POLICY "Allow admins to read contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com');

  -- Aggiorna la policy di aggiornamento
  ALTER POLICY "Allow admins to update contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'fracabu@gmail.com');

  -- Aggiorna la policy di eliminazione
  ALTER POLICY "Allow admins to delete contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com');
END $$;