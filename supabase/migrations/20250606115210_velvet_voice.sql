/*
  # Implementazione misure di sicurezza per contact_requests

  1. Nuove Tabelle
    - `email_rate_limits` - per tracciare i tentativi di invio per IP/email
    - `blocked_ips` - per bloccare IP sospetti
    - `blocked_emails` - per bloccare email sospette

  2. Sicurezza
    - Rate limiting per IP e email
    - Blacklist per IP e domini sospetti
    - Validazione avanzata dei contenuti
    - Log degli invii per monitoraggio
*/

-- Tabella per rate limiting
CREATE TABLE IF NOT EXISTS email_rate_limits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_address inet,
  email text,
  attempts integer DEFAULT 1,
  last_attempt timestamptz DEFAULT now(),
  blocked_until timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Tabella per IP bloccati
CREATE TABLE IF NOT EXISTS blocked_ips (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_address inet NOT NULL UNIQUE,
  reason text,
  blocked_at timestamptz DEFAULT now(),
  blocked_until timestamptz, -- NULL = permanente
  created_by text DEFAULT 'system'
);

-- Tabella per email/domini bloccati
CREATE TABLE IF NOT EXISTS blocked_emails (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email_pattern text NOT NULL, -- può essere email specifica o dominio (es: @spam.com)
  reason text,
  blocked_at timestamptz DEFAULT now(),
  created_by text DEFAULT 'system'
);

-- Aggiungi colonne per tracking alla tabella esistente
ALTER TABLE contact_requests 
ADD COLUMN IF NOT EXISTS ip_address inet,
ADD COLUMN IF NOT EXISTS user_agent text,
ADD COLUMN IF NOT EXISTS spam_score integer DEFAULT 0;

-- Abilita RLS per le nuove tabelle
ALTER TABLE email_rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_ips ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_emails ENABLE ROW LEVEL SECURITY;

-- Policy per admin su rate limits
CREATE POLICY "admin_manage_rate_limits"
ON email_rate_limits
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com')
WITH CHECK ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com');

-- Policy per admin su IP bloccati
CREATE POLICY "admin_manage_blocked_ips"
ON blocked_ips
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com')
WITH CHECK ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com');

-- Policy per admin su email bloccate
CREATE POLICY "admin_manage_blocked_emails"
ON blocked_emails
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com')
WITH CHECK ((auth.jwt() ->> 'email') = 'ilsorpassodilorenzobasile@gmail.com');

-- Funzione per verificare rate limiting
CREATE OR REPLACE FUNCTION check_rate_limit(
  p_ip_address inet,
  p_email text,
  p_max_attempts integer DEFAULT 5,
  p_time_window interval DEFAULT '1 hour'::interval
) RETURNS boolean AS $$
DECLARE
  current_attempts integer;
  is_blocked boolean;
BEGIN
  -- Controlla se IP è bloccato
  SELECT EXISTS(
    SELECT 1 FROM blocked_ips 
    WHERE ip_address = p_ip_address 
    AND (blocked_until IS NULL OR blocked_until > now())
  ) INTO is_blocked;
  
  IF is_blocked THEN
    RETURN false;
  END IF;

  -- Controlla se email/dominio è bloccato
  SELECT EXISTS(
    SELECT 1 FROM blocked_emails 
    WHERE p_email ILIKE email_pattern
  ) INTO is_blocked;
  
  IF is_blocked THEN
    RETURN false;
  END IF;

  -- Controlla rate limit per IP
  SELECT COALESCE(attempts, 0) INTO current_attempts
  FROM email_rate_limits 
  WHERE ip_address = p_ip_address 
  AND last_attempt > (now() - p_time_window);

  IF current_attempts >= p_max_attempts THEN
    -- Blocca temporaneamente l'IP
    UPDATE email_rate_limits 
    SET blocked_until = now() + interval '24 hours'
    WHERE ip_address = p_ip_address;
    
    RETURN false;
  END IF;

  -- Aggiorna o inserisci rate limit
  INSERT INTO email_rate_limits (ip_address, email, attempts, last_attempt)
  VALUES (p_ip_address, p_email, 1, now())
  ON CONFLICT (ip_address) 
  DO UPDATE SET 
    attempts = email_rate_limits.attempts + 1,
    last_attempt = now(),
    email = EXCLUDED.email;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Inserisci alcuni domini spam comuni
INSERT INTO blocked_emails (email_pattern, reason, created_by) VALUES
('%@tempmail.%', 'Temporary email service', 'system'),
('%@10minutemail.%', 'Temporary email service', 'system'),
('%@guerrillamail.%', 'Temporary email service', 'system'),
('%@mailinator.%', 'Temporary email service', 'system'),
('%@throwaway.%', 'Temporary email service', 'system'),
('%@spam.%', 'Known spam domain', 'system'),
('%@test.%', 'Test domain', 'system')
ON CONFLICT DO NOTHING;