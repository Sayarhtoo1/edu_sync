-- Add missing functions referenced by frontend services

-- 1. upsert_exam_subject function
CREATE OR REPLACE FUNCTION "public"."upsert_exam_subject"(
    "p_exam_id" "uuid",
    "p_subject_id" "uuid",
    "p_max_marks" integer,
    "p_passing_marks" integer
) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_exam_subject_id UUID;
BEGIN
    INSERT INTO public.exam_subjects (exam_id, subject_id, max_marks, passing_marks)
    VALUES (p_exam_id, p_subject_id, p_max_marks, p_passing_marks)
    ON CONFLICT (exam_id, subject_id) DO UPDATE
    SET
        max_marks = p_max_marks,
        passing_marks = p_passing_marks,
        updated_at = NOW()
    RETURNING id INTO new_exam_subject_id;

    RETURN new_exam_subject_id;
END;
$$;

ALTER FUNCTION "public"."upsert_exam_subject"("p_exam_id" "uuid", "p_subject_id" "uuid", "p_max_marks" integer, "p_passing_marks" integer) OWNER TO "postgres";

-- 2. get_detailed_student_report_card function
CREATE OR REPLACE FUNCTION "public"."get_detailed_student_report_card"(
    "p_student_id" integer,
    "p_exam_id" "uuid"
) RETURNS TABLE(
    "student_name" "text",
    "class_name" "text",
    "exam_name" "text",
    "exam_date" "date",
    "subject_name" "text",
    "marks_obtained" integer,
    "total_marks" integer,
    "percentage" numeric,
    "grade_name" "text",
    "grade_remarks" "text",
    "pass_fail_status" "text"
)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.full_name AS student_name,
        c.name AS class_name,
        e.name AS exam_name,
        e.exam_date,
        sub.name AS subject_name,
        sem.marks_obtained,
        es.max_marks AS total_marks,
        ROUND((sem.marks_obtained::numeric / es.max_marks::numeric) * 100, 2) AS percentage,
        g.grade_name,
        g.remarks AS grade_remarks,
        CASE
            WHEN sem.marks_obtained >= es.passing_marks THEN 'PASS'
            ELSE 'FAIL'
        END AS pass_fail_status
    FROM public.student_exam_marks sem
    JOIN public.students s ON sem.student_id = s.id
    JOIN public.classes c ON s.class_id = c.id
    JOIN public.exams e ON sem.exam_id = e.id
    JOIN public.subjects sub ON sem.subject_id = sub.id
    JOIN public.exam_subjects es ON sem.exam_id = es.exam_id AND sem.subject_id = es.subject_id
    LEFT JOIN public.grades g ON s.school_id = g.school_id
        AND (sem.marks_obtained::numeric / es.max_marks::numeric) * 100 BETWEEN g.min_percentage AND g.max_percentage
    WHERE sem.student_id = p_student_id AND sem.exam_id = p_exam_id
    ORDER BY sub.name;
END;
$$;

ALTER FUNCTION "public"."get_detailed_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") OWNER TO "postgres";

-- 3. get_student_performance function
CREATE OR REPLACE FUNCTION "public"."get_student_performance"(
    "p_student_id" integer,
    "p_academic_year" "text" DEFAULT NULL
) RETURNS TABLE(
    "exam_id" "uuid",
    "exam_name" "text",
    "exam_date" "date",
    "subject_name" "text",
    "marks_obtained" integer,
    "total_marks" integer,
    "percentage" numeric,
    "grade_name" "text",
    "class_rank" integer,
    "overall_percentage" numeric
)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH student_scores AS (
        SELECT
            sem.exam_id,
            e.name AS exam_name,
            e.exam_date,
            sub.name AS subject_name,
            sem.marks_obtained,
            es.max_marks AS total_marks,
            ROUND((sem.marks_obtained::numeric / es.max_marks::numeric) * 100, 2) AS percentage,
            g.grade_name,
            s.class_id,
            ROW_NUMBER() OVER (PARTITION BY sem.exam_id ORDER BY sem.marks_obtained DESC) AS exam_rank
        FROM public.student_exam_marks sem
        JOIN public.exams e ON sem.exam_id = e.id
        JOIN public.subjects sub ON sem.subject_id = sub.id
        JOIN public.exam_subjects es ON sem.exam_id = es.exam_id AND sem.subject_id = es.subject_id
        JOIN public.students s ON sem.student_id = s.id
        LEFT JOIN public.grades g ON s.school_id = g.school_id
            AND (sem.marks_obtained::numeric / es.max_marks::numeric) * 100 BETWEEN g.min_percentage AND g.max_percentage
        WHERE sem.student_id = p_student_id
        ORDER BY e.exam_date DESC, sub.name
    ),
    overall_scores AS (
        SELECT
            exam_id,
            AVG(percentage) AS overall_percentage
        FROM student_scores
        GROUP BY exam_id
    )
    SELECT
        ss.exam_id,
        ss.exam_name,
        ss.exam_date,
        ss.subject_name,
        ss.marks_obtained,
        ss.total_marks,
        ss.percentage,
        ss.grade_name,
        ss.exam_rank AS class_rank,
        os.overall_percentage
    FROM student_scores ss
    JOIN overall_scores os ON ss.exam_id = os.exam_id
    ORDER BY ss.exam_date DESC, ss.subject_name;
END;
$$;

ALTER FUNCTION "public"."get_student_performance"("p_student_id" integer, "p_academic_year" "text") OWNER TO "postgres";

-- Grant permissions for the new functions
GRANT ALL ON FUNCTION "public"."upsert_exam_subject"("p_exam_id" "uuid", "p_subject_id" "uuid", "p_max_marks" integer, "p_passing_marks" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_exam_subject"("p_exam_id" "uuid", "p_subject_id" "uuid", "p_max_marks" integer, "p_passing_marks" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_exam_subject"("p_exam_id" "uuid", "p_subject_id" "uuid", "p_max_marks" integer, "p_passing_marks" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_exam_subject"("p_exam_id" "uuid", "p_subject_id" "uuid", "p_max_marks" integer, "p_passing_marks" integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."get_detailed_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_detailed_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_detailed_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_detailed_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_student_performance"("p_student_id" integer, "p_academic_year" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_student_performance"("p_student_id" integer, "p_academic_year" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_student_performance"("p_student_id" integer, "p_academic_year" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_student_performance"("p_student_id" integer, "p_academic_year" "text") TO "service_role";