/*
  # Update Resend API key in notification function

  1. Changes
    - Update the notify_admin_contact_request function with the actual Resend API key
*/

-- Drop existing trigger first
DROP TRIGGER IF EXISTS contact_request_notification ON contact_requests;

-- Drop existing function
DROP FUNCTION IF EXISTS notify_admin_contact_request();

-- Create the function with the actual Resend API key
CREATE FUNCTION notify_admin_contact_request()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://api.resend.com/emails',
    headers := jsonb_build_object(
      'Authorization', 'Bearer re_23MBPtk3_MvEEuNx5LfdyRnsg6GUj9uu1',
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

-- Create the trigger
CREATE TRIGGER contact_request_notification
AFTER INSERT ON contact_requests
FOR EACH ROW
EXECUTE FUNCTION notify_admin_contact_request();