/*
  # Update contact requests policies

  1. Changes
    - Update insert policy to allow public inserts with proper checks
    - Ensure email and name are required
    - Add validation for message length

  2. Security
    - Maintain RLS enabled
    - Allow public inserts with validation
    - Keep admin-only access for read/update/delete
*/

-- Update the insert policy with proper validation
DROP POLICY IF EXISTS "Allow public to insert contact requests" ON contact_requests;

CREATE POLICY "Allow public to insert contact requests"
ON contact_requests
FOR INSERT
TO public
WITH CHECK (
  -- Ensure required fields are not empty
  length(name) > 0 AND
  length(email) > 0 AND
  length(message) > 0 AND
  -- Basic email format validation
  email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND
  -- Limit message length
  length(message) <= 1000
);