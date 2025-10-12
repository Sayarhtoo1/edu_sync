-- Add missing fields to students table
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS guardian_phone TEXT;

-- Update the create_student_and_link_parent function to include all fields
CREATE OR REPLACE FUNCTION public.create_student_and_link_parent(
  p_student_name TEXT,
  p_school_id INTEGER,
  p_class_id INTEGER,
  p_parent_id UUID,
  p_relation_type TEXT,
  p_date_of_birth DATE DEFAULT NULL,
  p_profile_photo_url TEXT DEFAULT NULL,
  p_gender TEXT DEFAULT NULL,
  p_guardian_phone TEXT DEFAULT NULL
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  new_student_id INT;
BEGIN
  -- Create the student with all fields
  INSERT INTO public.students (
    full_name, 
    school_id, 
    class_id, 
    date_of_birth, 
    profile_photo_url,
    gender,
    guardian_phone
  )
  VALUES (
    p_student_name, 
    p_school_id, 
    p_class_id, 
    p_date_of_birth, 
    p_profile_photo_url,
    p_gender,
    p_guardian_phone
  )
  RETURNING id INTO new_student_id;

  -- Link the student to the parent
  INSERT INTO public.parent_student_relations (parent_id, student_id, relation_type)
  VALUES (p_parent_id, new_student_id, p_relation_type);

  RETURN new_student_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$;
