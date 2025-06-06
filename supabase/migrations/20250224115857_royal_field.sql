/*
  # Update contact notification system
  
  1. Changes
    - Remove previous trigger and function that used net extension
    - Add webhook URL column to store Edge Function endpoint
    - Update trigger to use webhook
*/

-- Drop existing trigger first
DROP TRIGGER IF EXISTS contact_request_notification ON contact_requests;

-- Drop existing function
DROP FUNCTION IF EXISTS notify_admin_contact_request();

-- Add webhook_url column to store the Edge Function endpoint
ALTER TABLE contact_requests 
ADD COLUMN IF NOT EXISTS webhook_url text;

-- Create the function to handle notifications
CREATE OR REPLACE FUNCTION handle_contact_request()
RETURNS TRIGGER AS $$
BEGIN
  -- Set the webhook URL for the Edge Function
  NEW.webhook_url := 'https://hbqrubwqiysombwoxcea.functions.supabase.co/send-email';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER contact_request_notification
BEFORE INSERT ON contact_requests
FOR EACH ROW
EXECUTE FUNCTION handle_contact_request();