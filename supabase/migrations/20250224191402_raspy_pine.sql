/*
  # Fix contact form policies

  1. Changes
    - Drop all existing policies
    - Create a single, simple policy for public inserts
    - Create a single policy for admin access
    - Ensure RLS is enabled
*/

-- First, drop all existing policies
DROP POLICY IF EXISTS "Allow admins to read contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to update contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to delete contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow public to insert contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admin to manage contact requests" ON contact_requests;

-- Enable RLS
ALTER TABLE contact_requests ENABLE ROW LEVEL SECURITY;

-- Create a simple insert policy for public access with basic validation
CREATE POLICY "public_insert_contact_requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (
  name IS NOT NULL AND
  email IS NOT NULL AND
  message IS NOT NULL
);

-- Create a single policy for admin access to all operations
CREATE POLICY "admin_manage_contact_requests"
ON contact_requests
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'fracabu@gmail.com');