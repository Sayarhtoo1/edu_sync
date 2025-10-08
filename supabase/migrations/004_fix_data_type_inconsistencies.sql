-- Fix data type inconsistencies between frontend and backend

-- Fix: exams.class_id should be integer to match classes.id (integer), not UUID
-- This was incorrectly changed in the previous migration

ALTER TABLE "public"."exams" ALTER COLUMN "class_id" TYPE integer USING "class_id"::integer;

-- Drop the incorrect foreign key constraint that was added
ALTER TABLE "public"."exams" DROP CONSTRAINT IF EXISTS "exams_class_id_fkey";

-- Add the correct foreign key constraint for integer class_id
ALTER TABLE "public"."exams"
    ADD CONSTRAINT "exams_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE SET NULL;

-- Update the add_exam function to use integer class_id
DROP FUNCTION IF EXISTS "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer);

CREATE OR REPLACE FUNCTION "public"."add_exam"(
    "p_class_id" integer,
    "p_school_id" integer,
    "p_name" "text",
    "p_exam_date" "date",
    "p_examiner_name" "text",
    "p_description" "text" DEFAULT NULL,
    "p_max_marks" integer DEFAULT 100
) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_exam_id UUID;
BEGIN
    INSERT INTO public.exams (class_id, school_id, name, exam_date, examiner_name, description, max_marks)
    VALUES (p_class_id, p_school_id, p_name, p_exam_date, p_examiner_name, p_description, p_max_marks)
    RETURNING id INTO new_exam_id;

    RETURN new_exam_id;
END;
$$;

ALTER FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) OWNER TO "postgres";

-- Update the update_exam function to use integer class_id
DROP FUNCTION IF EXISTS "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer);

CREATE OR REPLACE FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text" DEFAULT NULL, "p_max_marks" integer DEFAULT 100) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
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
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

ALTER FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) OWNER TO "postgres";

-- Grant permissions for the corrected functions
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "service_role";