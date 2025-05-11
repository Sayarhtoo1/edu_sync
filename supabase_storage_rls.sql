-- RLS Policies for 'edusync' bucket

-- Policy: Admin can manage school logos
-- Allows admins to insert/update objects in the 'schools/<their_school_id>/' path.
CREATE POLICY "Admin can manage school logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'schools' AND
  EXISTS (
    SELECT 1
    FROM public.users
    WHERE users.id = auth.uid()
      AND users.role = 'Admin'
      AND users.school_id::text = (storage.foldername(name))[2]
  )
);

CREATE POLICY "Admin can update school logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'schools' AND
  EXISTS (
    SELECT 1
    FROM public.users
    WHERE users.id = auth.uid()
      AND users.role = 'Admin'
      AND users.school_id::text = (storage.foldername(name))[2]
  )
);

-- Policy: Authenticated can view school logos
-- Allows any authenticated user to select/read objects from the 'schools/' path.
CREATE POLICY "Authenticated can view school logos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'schools'
);

-- Policy: Users can manage own profile photo
-- Allows authenticated users to insert/update objects in 'users/profile_photos/<their_own_user_id>/' path.
CREATE POLICY "Users can manage own profile photo"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  (storage.foldername(name))[3] = auth.uid()::text
);

CREATE POLICY "Users can update own profile photo"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy: Users can view relevant profile photos
-- Allows users to view their own photo.
-- Allows Admins/Teachers to view photos of users within their same school.
CREATE POLICY "Users can view relevant profile photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'users' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  (
    ((storage.foldername(name))[3] = auth.uid()::text) OR -- User can view their own
    EXISTS ( -- Admin/Teacher can view users in their school
      SELECT 1
      FROM public.users requester_profile
      JOIN public.users target_user_profile ON ((storage.foldername(name))[3]) = target_user_profile.id::text
      WHERE requester_profile.id = auth.uid()
        AND requester_profile.school_id = target_user_profile.school_id
        AND (requester_profile.role = 'Admin' OR requester_profile.role = 'Teacher')
    )
  )
);

-- Policy: Teachers can manage lesson plan documents
-- Assumes path: lessonplans/<teacher_id>/<timestamp_or_filename>
CREATE POLICY "Teachers can manage lesson plan documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'lessonplans' AND
  (storage.foldername(name))[2] = auth.uid()::text AND -- Teacher can only write to their own folder
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'Teacher')
);

CREATE POLICY "Teachers can update their lesson plan documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'lessonplans' AND
  (storage.foldername(name))[2] = auth.uid()::text AND
  EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'Teacher')
);


-- Policy: Authenticated school members can view lesson plan documents
-- (Teachers of the class, Parents of students in the class, Admins of the school)
CREATE POLICY "School members can view lesson plan documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'lessonplans' AND
  EXISTS (
    SELECT 1
    FROM public.lesson_plans lp
    JOIN public.users u_teacher ON lp.teacher_id = u_teacher.id
    JOIN public.classes c ON lp.class_id = c.id
    JOIN public.users requester ON requester.id = auth.uid()
    WHERE u_teacher.id::text = (storage.foldername(name))[2] -- Document belongs to the teacher in path
    AND requester.school_id = c.school_id -- Requester is in the same school as the class of the lesson plan
    AND (
      requester.role = 'Admin' OR -- Admin can view
      requester.id = lp.teacher_id OR -- Teacher of the lesson plan can view
      EXISTS ( -- Parent of a student in the class of the lesson plan can view
        SELECT 1
        FROM public.students s
        JOIN public.parent_student_relations psr ON s.id = psr.student_id
        WHERE psr.parent_id = auth.uid() AND s.class_id = lp.class_id
      )
    )
  )
);

-- Note: Policies for student profile photos would be similar to user profile photos,
-- but access might be granted to admins, teachers of the student's class, and linked parents.
-- Example for students (path: students/profile_photos/<student_id>/<filename.ext>):

-- Policy: Admins/Teachers can manage student profile photos
CREATE POLICY "Staff can manage student profile photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'students' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  EXISTS (
    SELECT 1
    FROM public.users u
    JOIN public.students s ON u.school_id = s.school_id
    WHERE u.id = auth.uid()
      AND (u.role = 'Admin' OR u.role = 'Teacher') -- Or more specific: teacher of that student's class
      AND s.id::text = (storage.foldername(name))[3]
  )
);
CREATE POLICY "Staff can update student profile photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'students' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  EXISTS (
    SELECT 1
    FROM public.users u
    JOIN public.students s ON u.school_id = s.school_id
    WHERE u.id = auth.uid()
      AND (u.role = 'Admin' OR u.role = 'Teacher')
      AND s.id::text = (storage.foldername(name))[3]
  )
);


-- Policy: Relevant users can view student profile photos
CREATE POLICY "Relevant users can view student profile photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'edusync' AND
  (storage.foldername(name))[1] = 'students' AND
  (storage.foldername(name))[2] = 'profile_photos' AND
  EXISTS (
    SELECT 1
    FROM public.users u
    JOIN public.students s ON (storage.foldername(name))[3] = s.id::text -- student_id from path
    WHERE u.id = auth.uid() AND u.school_id = s.school_id -- user and student in same school
    AND (
      u.role = 'Admin' OR
      u.role = 'Teacher' OR -- Could be refined to teacher of student's class
      EXISTS ( -- Parent of the student
        SELECT 1 FROM public.parent_student_relations psr
        WHERE psr.student_id = s.id AND psr.parent_id = auth.uid()
      )
    )
  )
);

-- IMPORTANT: Remember to enable RLS on the 'edusync' bucket itself in the Supabase dashboard.
-- These policies define WHO can do WHAT, but RLS must be turned on for the bucket.
