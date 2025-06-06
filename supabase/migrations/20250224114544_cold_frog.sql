/*
  # Add email notification for contact forms

  1. Changes
    - Create a new function to handle email notifications
    - Add trigger to send email on new contact requests
  
  2. Security
    - Function runs with security definer to ensure email sending permissions
*/

-- Create the function to send email notifications
CREATE OR REPLACE FUNCTION notify_admin_contact_request()
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
      'to', 'ilsorpassodilorenzobasile@gmail.com',
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

-- Create the trigger
CREATE TRIGGER contact_request_notification
AFTER INSERT ON contact_requests
FOR EACH ROW
EXECUTE FUNCTION notify_admin_contact_request();