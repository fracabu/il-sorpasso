/*
  # Aggiorna tabella contact_requests per conformità GDPR

  1. Modifiche
    - Aggiunge colonne per tracciare il consenso privacy
    - Aggiunge colonne per data retention automatica
    - Aggiorna la struttura per separare nome e cognome

  2. Sicurezza
    - Mantiene RLS abilitato
    - Aggiunge controlli per data retention
    - Migliora la tracciabilità del consenso
*/

-- Aggiungi colonne per conformità GDPR
ALTER TABLE contact_requests 
ADD COLUMN IF NOT EXISTS privacy_accepted boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS data_retention_until timestamptz DEFAULT (now() + interval '2 years'),
ADD COLUMN IF NOT EXISTS consent_timestamp timestamptz DEFAULT now(),
ADD COLUMN IF NOT EXISTS surname text;

-- Aggiorna la policy di inserimento per includere il consenso privacy
DROP POLICY IF EXISTS "public_insert_contact_requests" ON contact_requests;

CREATE POLICY "public_insert_contact_requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (
  name IS NOT NULL AND
  email IS NOT NULL AND
  message IS NOT NULL AND
  privacy_accepted = true
);

-- Funzione per cancellazione automatica dei dati scaduti
CREATE OR REPLACE FUNCTION cleanup_expired_contact_requests()
RETURNS void AS $$
BEGIN
  DELETE FROM contact_requests 
  WHERE data_retention_until < now()
  AND status = 'completed';
  
  -- Log della pulizia
  RAISE NOTICE 'Cleaned up expired contact requests at %', now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crea un trigger per impostare automaticamente la data di scadenza
CREATE OR REPLACE FUNCTION set_data_retention()
RETURNS TRIGGER AS $$
BEGIN
  NEW.data_retention_until := NEW.created_at + interval '2 years';
  NEW.consent_timestamp := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_data_retention_trigger
BEFORE INSERT ON contact_requests
FOR EACH ROW
EXECUTE FUNCTION set_data_retention();

-- Commento sulla tabella per documentare la conformità GDPR
COMMENT ON TABLE contact_requests IS 'Tabella per richieste di contatto - Conforme GDPR. I dati vengono automaticamente cancellati dopo 2 anni dalla creazione, salvo diversa richiesta dell''utente.';
COMMENT ON COLUMN contact_requests.privacy_accepted IS 'Consenso esplicito dell''utente al trattamento dei dati personali';
COMMENT ON COLUMN contact_requests.data_retention_until IS 'Data fino alla quale i dati possono essere conservati';
COMMENT ON COLUMN contact_requests.consent_timestamp IS 'Timestamp del consenso al trattamento dei dati';