/*
  # Add Gmail admin to RLS policies

  1. Changes
    - Update RLS policies to include the Gmail admin address
    - Affects all contact_requests table policies
  
  2. Security
    - Maintains existing security model
    - Adds new admin email to authorized users
*/

DO $$ 
BEGIN
  -- Update select policy
  ALTER POLICY "Allow admins to read contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it',
    'ilsorpassodilorenzobasile@gmail.com'
  ));

  -- Update update policy
  ALTER POLICY "Allow admins to update contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it',
    'ilsorpassodilorenzobasile@gmail.com'
  ))
  WITH CHECK (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it',
    'ilsorpassodilorenzobasile@gmail.com'
  ));

  -- Update delete policy
  ALTER POLICY "Allow admins to delete contact requests" 
  ON contact_requests 
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it',
    'ilsorpassodilorenzobasile@gmail.com'
  ));
END $$;