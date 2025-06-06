/*
  # Update policies and notifications for new admin

  1. Changes
    - Update RLS policies to include new admin email
    - Update notification function with new admin email
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
  PERFORM net.http_post(
    url := 'https://api.resend.com/emails',
    headers := jsonb_build_object(
      'Authorization', 'Bearer re_123...', -- Replace with your actual Resend API key
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