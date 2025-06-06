/*
  # Update admin email configuration

  1. Changes
    - Update admin email in RLS policies from ilsorpassodilorenzobasile@gmail.com to fracabu@gmail.com
    - Update notification recipient email to fracabu@gmail.com

  2. Security
    - Updates existing RLS policies to use new admin email
    - Maintains all existing security constraints
*/

-- Drop existing trigger first
DROP TRIGGER IF EXISTS contact_request_notification ON contact_requests;

-- Drop existing function
DROP FUNCTION IF EXISTS notify_admin_contact_request();

-- Update select policy
ALTER POLICY "Allow admins to read contact requests" 
ON contact_requests 
USING (auth.jwt() ->> 'email' IN (
  'admin@ilsorpasso.it',
  'fracabu@gmail.com'
));

-- Update update policy
ALTER POLICY "Allow admins to update contact requests" 
ON contact_requests 
USING (auth.jwt() ->> 'email' IN (
  'admin@ilsorpasso.it',
  'fracabu@gmail.com'
))
WITH CHECK (auth.jwt() ->> 'email' IN (
  'admin@ilsorpasso.it',
  'fracabu@gmail.com'
));

-- Update delete policy
ALTER POLICY "Allow admins to delete contact requests" 
ON contact_requests 
USING (auth.jwt() ->> 'email' IN (
  'admin@ilsorpasso.it',
  'fracabu@gmail.com'
));

-- Create the new function with updated email
CREATE FUNCTION notify_admin_contact_request()
RETURNS TRIGGER AS $$
BEGIN
  SELECT net.http_post(
    url := 'https://api.resend.com/emails',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.settings.resend_api_key'),
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'from', 'Il Sorpasso <noreply@ilsorpasso.it>',
      'to', 'fracabu@gmail.com',
      'subject', 'Nuova richiesta di contatto da ' || NEW.name,
      'html', '<h2>Nuova richiesta di contatto</h2>' ||
              '<p><strong>Nome:</strong> ' || NEW.name || '</p>' ||
              '<p><strong>Email:</strong> ' || NEW.email || '</p>' ||
              '<p><strong>Messaggio:</strong></p>' ||
              '<p>' || NEW.message || '</p>'
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the new trigger
CREATE TRIGGER contact_request_notification
AFTER INSERT ON contact_requests
FOR EACH ROW
EXECUTE FUNCTION notify_admin_contact_request();