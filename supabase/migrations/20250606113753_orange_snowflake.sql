/*
  # Create Admin Users Setup

  1. Security
    - This migration provides instructions for creating admin users
    - Admin users must be created through Supabase Auth, not SQL
  
  2. Notes
    - Users need to be created manually in Supabase Dashboard
    - Or through the application's signup flow
    - This file serves as documentation for the required admin accounts
*/

-- Note: Admin users cannot be created directly via SQL migration
-- They must be created through Supabase Auth system

-- Required admin accounts:
-- 1. fracabu@gmail.com (password: admin)
-- 2. ilsorpassodilorenzobasile@gmail.com (password: admin)

-- To create these users, either:
-- 1. Go to Supabase Dashboard > Authentication > Users > Add User
-- 2. Or use the signup functionality in your application

-- The RLS policies are already configured to allow these specific emails
-- to manage contact requests once the users are created in the auth system