-- WARNING: These are permissive RLS policies for debugging purposes.
-- Replace with more secure policies for production.

-- Step 1: Delete existing policies for the 'edusync' bucket.
-- You might need to run these one by one if a policy doesn't exist, it will error.
-- Or, query policy names first: SELECT policyname FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects';
-- Then drop them by name.

-- Example of how to drop policies (replace 'PolicyName1', 'PolicyName2' with actual names):
-- DROP POLICY IF EXISTS "PolicyName1" ON storage.objects;
-- DROP POLICY IF EXISTS "PolicyName2" ON storage.objects;
-- ... and so on for all policies on storage.objects for the 'edusync' bucket.

-- It's often easier to delete them from the Supabase Dashboard UI (Storage -> Policies -> Select bucket -> Delete policies).
-- If you want to do it via SQL, you'd list them and drop them.
-- For now, I'll provide the CREATE statements for the permissive policies.
-- Please ensure you've removed the old ones first to avoid conflicts or unintended behavior.

-- Step 2: Create new permissive policies for the 'edusync' bucket.

-- Policy: Allow all authenticated users to SELECT (read) objects from 'edusync' bucket.
CREATE POLICY "Authenticated users can select all objects in edusync"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'edusync');

-- Policy: Allow all authenticated users to INSERT objects into 'edusync' bucket.
CREATE POLICY "Authenticated users can insert any object into edusync"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'edusync');

-- Policy: Allow all authenticated users to UPDATE objects in 'edusync' bucket.
CREATE POLICY "Authenticated users can update any object in edusync"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'edusync')
WITH CHECK (bucket_id = 'edusync');

-- Policy: Allow all authenticated users to DELETE objects from 'edusync' bucket.
-- (Be cautious with this in production)
CREATE POLICY "Authenticated users can delete any object from edusync"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'edusync');

-- IMPORTANT:
-- 1. Make sure RLS is ENABLED for the 'edusync' bucket in the Supabase Dashboard.
-- 2. These policies grant broad access. Once the immediate issue is resolved,
--    you should replace these with more granular, secure RLS policies based on your application's needs.
--    The previous, more specific policies I provided are a better starting point for secure RLS,
--    but they need to be debugged if they cause recursion.
