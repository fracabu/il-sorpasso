/*
  # Create contact requests table

  1. New Tables
    - `contact_requests`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text)
      - `message` (text)
      - `status` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS
    - Add policies for admin access
*/

CREATE TABLE IF NOT EXISTS contact_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'new',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE contact_requests ENABLE ROW LEVEL SECURITY;

-- Policy to allow admins to read all contact requests
CREATE POLICY "Allow admins to read contact requests"
  ON contact_requests
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it'
  ));

-- Policy to allow anyone to insert contact requests
CREATE POLICY "Allow public to insert contact requests"
  ON contact_requests
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Policy to allow admins to update contact requests
CREATE POLICY "Allow admins to update contact requests"
  ON contact_requests
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it'
  ))
  WITH CHECK (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it'
  ));

-- Policy to allow admins to delete contact requests
CREATE POLICY "Allow admins to delete contact requests"
  ON contact_requests
  FOR DELETE
  TO authenticated
  USING (auth.jwt() ->> 'email' IN (
    'admin@ilsorpasso.it'
  ));