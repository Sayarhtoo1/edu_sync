-- Fix delete_exam function parameter name to match service call

DROP FUNCTION IF EXISTS public.delete_exam(uuid);

CREATE OR REPLACE FUNCTION public.delete_exam(
  p_exam_id uuid
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM public.exams WHERE id = p_exam_id;
END;
$$;

ALTER FUNCTION public.delete_exam(uuid) OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.delete_exam(uuid) TO supabase_admin;
GRANT EXECUTE ON FUNCTION public.delete_exam(uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.delete_exam(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_exam(uuid) TO service_role;
