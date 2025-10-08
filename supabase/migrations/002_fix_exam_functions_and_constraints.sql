-- Fix conflicting add_exam functions and data type issues (cleaned)

-- 1) Drop existing foreign key constraint if it exists
ALTER TABLE public.exams
  DROP CONSTRAINT IF EXISTS exams_class_id_fkey;

-- 2) Ensure class_id column is integer (classes.id is integer)
-- The column is already int4 in your schema; this is a no-op but kept for safety
ALTER TABLE public.exams
  ALTER COLUMN class_id TYPE integer;

-- 3) Recreate the foreign key constraint (will be created once)
ALTER TABLE public.exams
  ADD CONSTRAINT exams_class_id_fkey
  FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE SET NULL;

-- 4) Drop conflicting add_exam overloads (use types, not parameter names)
DROP FUNCTION IF EXISTS public.add_exam(uuid, integer, text, date, text);
DROP FUNCTION IF EXISTS public.add_exam(integer, integer, text, date, text, text, integer);

-- 5) Create a unified add_exam function (uses uuid exam id return)
CREATE OR REPLACE FUNCTION public.add_exam(
  p_class_id integer,
  p_school_id integer,
  p_name text,
  p_exam_date date,
  p_examiner_name text,
  p_description text DEFAULT NULL,
  p_max_marks integer DEFAULT 100
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  new_exam_id uuid;
BEGIN
  INSERT INTO public.exams (class_id, school_id, name, exam_date, examiner_name, description, max_marks)
  VALUES (p_class_id, p_school_id, p_name, p_exam_date, p_examiner_name, p_description, p_max_marks)
  RETURNING id INTO new_exam_id;

  RETURN new_exam_id;
END;
$$;

ALTER FUNCTION public.add_exam(integer, integer, text, date, text, text, integer) OWNER TO postgres;

-- 6) Create or replace update_exam to match class_id type
CREATE OR REPLACE FUNCTION public.update_exam(
  p_id uuid,
  p_class_id integer,
  p_name text,
  p_exam_date date,
  p_examiner_name text,
  p_description text DEFAULT NULL,
  p_max_marks integer DEFAULT 100
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.exams
  SET
    class_id = p_class_id,
    name = p_name,
    exam_date = p_exam_date,
    examiner_name = p_examiner_name,
    description = p_description,
    max_marks = p_max_marks,
    updated_at = now()
  WHERE id = p_id;
END;
$$;

ALTER FUNCTION public.update_exam(uuid, integer, text, date, text, text, integer) OWNER TO postgres;

-- 7) Grants: give EXECUTE on the functions to roles (safer than GRANT ALL)
GRANT EXECUTE ON FUNCTION public.add_exam(integer, integer, text, date, text, text, integer) TO supabase_admin;
GRANT EXECUTE ON FUNCTION public.add_exam(integer, integer, text, date, text, text, integer) TO anon;
GRANT EXECUTE ON FUNCTION public.add_exam(integer, integer, text, date, text, text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_exam(integer, integer, text, date, text, text, integer) TO service_role;

GRANT EXECUTE ON FUNCTION public.update_exam(uuid, integer, text, date, text, text, integer) TO supabase_admin;
GRANT EXECUTE ON FUNCTION public.update_exam(uuid, integer, text, date, text, text, integer) TO anon;
GRANT EXECUTE ON FUNCTION public.update_exam(uuid, integer, text, date, text, text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_exam(uuid, integer, text, date, text, text, integer) TO service_role;