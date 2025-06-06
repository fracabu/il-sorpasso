/*
  # Fix contact request policies

  1. Changes
    - Drop all existing policies
    - Create new simplified policies that:
      - Allow public inserts without authentication
      - Maintain admin access for fracabu@gmail.com
    
  2. Security
    - Public can only insert new requests
    - Admin can read, update, and delete requests
*/

-- First, drop all existing policies
DROP POLICY IF EXISTS "Allow admins to read contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to update contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to delete contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow public to insert contact requests" ON contact_requests;

-- Enable RLS
ALTER TABLE contact_requests ENABLE ROW LEVEL SECURITY;

-- Create a simple insert policy for public access
CREATE POLICY "Allow public to insert contact requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (true);

-- Create admin policies
CREATE POLICY "Allow admin to manage contact requests"
ON contact_requests
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'fracabu@gmail.com');