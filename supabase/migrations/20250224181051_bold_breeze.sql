/*
  # Fix RLS policies for contact_requests table

  1. Changes
    - Drop and recreate all policies with correct permissions
    - Ensure public insert works without authentication
    - Maintain admin-only access for other operations

  2. Security
    - Enable RLS
    - Allow unauthenticated inserts
    - Restrict read/update/delete to admin only
*/

-- First, drop all existing policies
DROP POLICY IF EXISTS "Allow admins to read contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to update contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow admins to delete contact requests" ON contact_requests;
DROP POLICY IF EXISTS "Allow public to insert contact requests" ON contact_requests;

-- Recreate the policies with correct permissions
-- 1. Insert policy for public (no auth required)
CREATE POLICY "Allow public to insert contact requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (true);

-- 2. Read policy for admin
CREATE POLICY "Allow admins to read contact requests"
ON contact_requests
FOR SELECT
TO authenticated
USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com');

-- 3. Update policy for admin
CREATE POLICY "Allow admins to update contact requests"
ON contact_requests
FOR UPDATE
TO authenticated
USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'fracabu@gmail.com');

-- 4. Delete policy for admin
CREATE POLICY "Allow admins to delete contact requests"
ON contact_requests
FOR DELETE
TO authenticated
USING (auth.jwt() ->> 'email' = 'fracabu@gmail.com');