

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."form_field_type" AS ENUM (
    'text',
    'yes_no',
    'multiple_choice',
    'checkbox',
    'number'
);


ALTER TYPE "public"."form_field_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_exam_id UUID;
BEGIN
    INSERT INTO public.exams (class_id, school_id, name, exam_date, examiner_name)
    VALUES (p_class_id, p_school_id, p_name, p_exam_date, p_examiner_name)
    RETURNING id INTO new_exam_id;

    RETURN new_exam_id;
END;
$$;


ALTER FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO exams (class_id, school_id, name, exam_date, examiner_name, description, max_marks)
  VALUES (p_class_id, p_school_id, p_name, p_exam_date, p_examiner_name, p_description, p_max_marks);
END;
$$;


ALTER FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_grade_id UUID;
BEGIN
    INSERT INTO public.grades (school_id, grade_name, min_percentage, max_percentage, remarks)
    VALUES (p_school_id, p_grade_name, p_min_percentage, p_max_percentage, p_remarks)
    RETURNING id INTO new_grade_id;

    RETURN new_grade_id;
END;
$$;


ALTER FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_subject_id UUID;
BEGIN
    INSERT INTO public.subjects (name, class_id, school_id)
    VALUES (p_name, p_class_id, p_school_id)
    RETURNING id INTO new_subject_id;

    RETURN new_subject_id;
END;
$$;


ALTER FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."subjects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "school_id" integer,
    "name" "text" NOT NULL,
    "code" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subjects" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") RETURNS SETOF "public"."subjects"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY INSERT INTO public.subjects (name, class_id, school_id)
    VALUES (p_name, p_class_id, p_school_id)
    RETURNING *;
END;
$$;


ALTER FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text" DEFAULT NULL::"text", "academic_year" "text" DEFAULT NULL::"text", "theme" "text" DEFAULT NULL::"text", "contact_info" "text" DEFAULT NULL::"text") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    new_school_id int;
begin
    -- Start a transaction
    begin
        -- Insert the new school
        insert into public.schools (name, logo_url, academic_year, theme, contact_info)
        values (school_name, logo_url, academic_year, theme, contact_info)
        returning id into new_school_id;

        -- Update the user's role to 'Admin' and assign the school_id
        update public.users
        set school_id = new_school_id,
            role = 'Admin'
        where id = admin_user_id;

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;
    
    return new_school_id;
end;
$$;


ALTER FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text", "academic_year" "text", "theme" "text", "contact_info" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date" DEFAULT NULL::"date", "p_profile_photo_url" "text" DEFAULT NULL::"text") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    new_student_id int;
begin
    -- Start a transaction
    begin
        -- 1. Create the student
        insert into public.students (full_name, school_id, class_id, date_of_birth, profile_photo_url)
        values (p_student_name, p_school_id, p_class_id, p_date_of_birth, p_profile_photo_url)
        returning id into new_student_id;

        -- 2. Link the student to the parent
        -- This assumes the parent user (p_parent_id) already exists.
        -- If a new parent needs to be created, that should be done in a separate transaction
        -- or handled by a more complex RPC that also creates the auth user.
        -- For simplicity, this RPC assumes the parent exists.
        insert into public.parent_student_relations (parent_id, student_id, relation_type)
        values (p_parent_id, new_student_id, p_relation_type);

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;

    return new_student_id;
end;
$$;


ALTER FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date", "p_profile_photo_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_exam"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    DELETE FROM public.exams
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_exam"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_grade"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    DELETE FROM public.grades
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_grade"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_subject"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    DELETE FROM public.subjects
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_subject"("p_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."custom_forms" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "created_by" "uuid",
    "school_id" integer,
    "active_from" timestamp without time zone,
    "active_to" timestamp without time zone,
    "is_daily" boolean DEFAULT false,
    "assign_to_whole_school" boolean DEFAULT false,
    "assigned_section_details" "jsonb" DEFAULT '[]'::"jsonb",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "assigned_class_ids" integer[] DEFAULT '{}'::integer[],
    "assigned_student_ids" integer[] DEFAULT '{}'::integer[]
);


ALTER TABLE "public"."custom_forms" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") RETURNS SETOF "public"."custom_forms"
    LANGUAGE "plpgsql"
    AS $$
begin
    return query
    select *
    from custom_forms
    where
        school_id = p_school_id and
        active_from <= p_date and
        active_to >= p_date and
        (
            assign_to_whole_school = true or
            assigned_student_ids @> array[p_student_id] or
            assigned_class_ids && p_class_ids
        );
end;
$$;


ALTER FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") RETURNS integer
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT school_id FROM public.users WHERE id = user_id_input AND role = 'Admin';
$$;


ALTER FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_auth_uid"() RETURNS "uuid"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
BEGIN
  RETURN auth.uid();
END;
$$;


ALTER FUNCTION "public"."get_auth_uid"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") RETURNS TABLE("student_id" integer, "student_name" "text", "subject_name" "text", "marks_obtained" integer, "grade_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id AS student_id,
        s.full_name AS student_name,
        sub.name AS subject_name,
        sem.marks_obtained,
        g.grade_name
    FROM
        public.student_exam_marks sem
    JOIN
        public.students s ON sem.student_id = s.id
    JOIN
        public.subjects sub ON sem.subject_id = sub.id
    LEFT JOIN
        public.grades g ON s.school_id = g.school_id AND sem.marks_obtained BETWEEN g.min_percentage AND g.max_percentage
    WHERE
        s.class_id = p_class_id AND sem.exam_id = p_exam_id;
END;
$$;


ALTER FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    total_students INT;
    avg_marks DECIMAL;
    pass_rate DECIMAL;
BEGIN
    -- Calculate total students in the class
    SELECT COUNT(id) INTO total_students FROM public.students WHERE class_id = p_class_id;

    -- Calculate average marks across all exams and subjects for the class
    SELECT COALESCE(AVG(sem.marks_obtained), 0) INTO avg_marks
    FROM public.student_exam_marks sem
    JOIN public.exams e ON sem.exam_id = e.id
    WHERE e.class_id = p_class_id;

    -- Calculate overall pass rate for the class
    SELECT COALESCE(CAST(SUM(CASE WHEN sem.marks_obtained >= es.passing_marks THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(sem.id), 0) INTO pass_rate
    FROM public.student_exam_marks sem
    JOIN public.exam_subjects es ON sem.subject_id = es.subject_id AND sem.exam_id = es.exam_id
    JOIN public.exams e ON sem.exam_id = e.id
    WHERE e.class_id = p_class_id;

    RETURN json_build_object(
        'total_students', total_students,
        'average_marks', avg_marks,
        'pass_rate', pass_rate
    );
END;
$$;


ALTER FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    total_students INT;
    avg_marks DECIMAL;
    pass_rate DECIMAL;
BEGIN
    -- Calculate total students in the school
    SELECT COUNT(id) INTO total_students FROM public.students WHERE school_id = p_school_id;

    -- Calculate average marks across all exams and subjects for the school
    SELECT COALESCE(AVG(sem.marks_obtained), 0) INTO avg_marks
    FROM public.student_exam_marks sem
    JOIN public.exams e ON sem.exam_id = e.id
    WHERE e.school_id = p_school_id;

    -- Calculate overall pass rate for the school
    SELECT COALESCE(CAST(SUM(CASE WHEN sem.marks_obtained >= es.passing_marks THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(sem.id), 0) INTO pass_rate
    FROM public.student_exam_marks sem
    JOIN public.exam_subjects es ON sem.subject_id = es.subject_id AND sem.exam_id = es.exam_id
    JOIN public.exams e ON sem.exam_id = e.id
    WHERE e.school_id = p_school_id;

    RETURN json_build_object(
        'total_students', total_students,
        'average_marks', avg_marks,
        'pass_rate', pass_rate
    );
END;
$$;


ALTER FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_student_progress"("p_student_id" integer) RETURNS SETOF "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'exam_name', e.name,
        'subject_name', s.name,
        'marks_obtained', sem.marks_obtained,
        'max_marks', es.max_marks,
        'exam_date', e.exam_date
    )
    FROM public.student_exam_marks sem
    JOIN public.exams e ON sem.exam_id = e.id
    JOIN public.subjects s ON sem.subject_id = s.id
    JOIN public.exam_subjects es ON sem.exam_id = es.exam_id AND sem.subject_id = es.subject_id
    WHERE sem.student_id = p_student_id
    ORDER BY e.exam_date, s.name;
END;
$$;


ALTER FUNCTION "public"."get_student_progress"("p_student_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") RETURNS TABLE("subject_name" "text", "marks_obtained" integer, "total_marks" integer, "grade_name" "text", "remarks" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.name AS subject_name,
        sem.marks_obtained,
        100 AS total_marks, -- Placeholder, adjust as per actual total marks logic
        g.grade_name,
        g.remarks
    FROM
        public.student_exam_marks sem
    JOIN
        public.subjects s ON sem.subject_id = s.id
    LEFT JOIN
        public.grades g ON sem.school_id = g.school_id AND sem.marks_obtained BETWEEN g.min_percentage AND g.max_percentage
    WHERE
        sem.student_id = p_student_id AND sem.exam_id = p_exam_id;
END;
$$;


ALTER FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_subject_performance"("p_school_id" integer DEFAULT NULL::integer, "p_class_id" integer DEFAULT NULL::integer) RETURNS SETOF "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF p_class_id IS NOT NULL THEN
        -- Subject performance for a specific class
        RETURN QUERY
        SELECT json_build_object(
            'subject_id', s.id,
            'subject_name', s.name,
            'average_marks', COALESCE(AVG(sem.marks_obtained), 0),
            'pass_rate', COALESCE(CAST(SUM(CASE WHEN sem.marks_obtained >= es.passing_marks THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(sem.id), 0),
            'grade_distribution', (SELECT json_agg(grade_data) FROM (
                SELECT g.grade_name, COUNT(DISTINCT st.id) AS student_count
                FROM public.student_exam_marks sem_inner
                JOIN public.exam_subjects es_inner ON sem_inner.subject_id = es_inner.subject_id AND sem_inner.exam_id = es_inner.exam_id
                JOIN public.students st ON sem_inner.student_id = st.id
                JOIN public.grades g ON (sem_inner.marks_obtained * 100.0 / es_inner.max_marks) BETWEEN g.min_percentage AND g.max_percentage
                WHERE sem_inner.subject_id = s.id AND st.class_id = p_class_id
                GROUP BY g.grade_name
            ) AS grade_data)
        )
        FROM public.subjects s
        LEFT JOIN public.student_exam_marks sem ON s.id = sem.subject_id
        LEFT JOIN public.exam_subjects es ON sem.subject_id = es.subject_id AND sem.exam_id = es.exam_id
        WHERE s.class_id = p_class_id
        GROUP BY s.id, s.name;
    ELSE
        -- Subject performance for an entire school
        RETURN QUERY
        SELECT json_build_object(
            'subject_id', s.id,
            'subject_name', s.name,
            'average_marks', COALESCE(AVG(sem.marks_obtained), 0),
            'pass_rate', COALESCE(CAST(SUM(CASE WHEN sem.marks_obtained >= es.passing_marks THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(sem.id), 0),
            'grade_distribution', (SELECT json_agg(grade_data) FROM (
                SELECT g.grade_name, COUNT(DISTINCT st.id) AS student_count
                FROM public.student_exam_marks sem_inner
                JOIN public.exam_subjects es_inner ON sem_inner.subject_id = es_inner.subject_id AND sem_inner.exam_id = es_inner.exam_id
                JOIN public.students st ON sem_inner.student_id = st.id
                JOIN public.grades g ON (sem_inner.marks_obtained * 100.0 / es_inner.max_marks) BETWEEN g.min_percentage AND g.max_percentage
                WHERE sem_inner.subject_id = s.id AND st.school_id = p_school_id
                GROUP BY g.grade_name
            ) AS grade_data)
        )
        FROM public.subjects s
        LEFT JOIN public.student_exam_marks sem ON s.id = sem.subject_id
        LEFT JOIN public.exam_subjects es ON sem.subject_id = es.subject_id AND sem.exam_id = es.exam_id
        WHERE s.school_id = p_school_id
        GROUP BY s.id, s.name;
    END IF;
END;
$$;


ALTER FUNCTION "public"."get_subject_performance"("p_school_id" integer, "p_class_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_public_user_settings"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
  INSERT INTO public.user_settings (user_id)
  VALUES (new.id);
  RETURN new;
END;
$$;


ALTER FUNCTION "public"."handle_new_public_user_settings"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.users (id, email, role, full_name, school_id)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'role', 'student'),
    new.raw_user_meta_data->>'full_name',
    coalesce(nullif(new.raw_user_meta_data->>'school_id', ''), 'NULL')::int
  )
  on conflict (id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_of_school"("school_id_param" integer) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = public.get_auth_uid()
      AND role = 'Admin'
      AND school_id = school_id_param
  );
END;
$$;


ALTER FUNCTION "public"."is_admin_of_school"("school_id_param" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    new_response_id uuid;
    answer_record jsonb;
begin
    -- Start a transaction
    begin
        -- 1. Insert the main form response
        insert into public.form_responses (form_id, student_id, parent_id, submitted_by)
        values (p_form_id, p_student_id, p_parent_id, p_submitted_by_id)
        returning id into new_response_id;

        -- 2. Loop through the JSON array of answers and insert them
        for answer_record in select * from jsonb_array_elements(p_answers)
        loop
            insert into public.form_response_answers (response_id, field_id, answer_text, answer_json)
            values (
                new_response_id,
                (answer_record->>'field_id')::uuid,
                answer_record->>'answer_text',
                answer_record->'answer_json' -- Assuming answer_json might be passed
            );
        end loop;

    exception
        when others then
            -- If any error occurs, roll back the transaction
            raise;
    end;

    return new_response_id;
end;
$$;


ALTER FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_set_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_set_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.exams
    SET
        class_id = p_class_id,
        name = p_name,
        exam_date = p_exam_date,
        examiner_name = p_examiner_name,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.grades
    SET
        grade_name = p_grade_name,
        min_percentage = p_min_percentage,
        max_percentage = p_max_percentage,
        remarks = p_remarks,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.subjects
    SET
        name = p_name,
        class_id = p_class_id,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_settings record;
  v_distance DOUBLE PRECISION;
  v_status TEXT;
  v_attendance_record staff_attendance;
  v_existing_attendance_id UUID;
BEGIN
  -- Get school settings
  SELECT * INTO v_settings FROM school_settings WHERE school_id = p_school_id;

  IF NOT FOUND THEN
    RETURN json_build_object('error', 'School settings not found.');
  END IF;

  -- Calculate distance
  v_distance := 6371000 * acos(
    cos(radians(p_latitude)) * cos(radians(v_settings.location_latitude)) *
    cos(radians(v_settings.location_longitude) - radians(p_longitude)) +
    sin(radians(p_latitude)) * sin(radians(v_settings.location_latitude))
  );

  IF v_distance > v_settings.attendance_radius_meters THEN
    RETURN json_build_object('error', 'You are outside the allowed attendance radius.');
  END IF;

  -- Check for an existing open attendance record for the current user
  SELECT id INTO v_existing_attendance_id
  FROM staff_attendance
  WHERE staff_id = auth.uid() AND check_out_timestamp IS NULL
  ORDER BY check_in_timestamp DESC
  LIMIT 1;

  IF v_existing_attendance_id IS NOT NULL THEN
    -- Clock-out
    UPDATE staff_attendance
    SET
      check_out_timestamp = now(),
      check_out_location = p_latitude || ',' || p_longitude
    WHERE id = v_existing_attendance_id
    RETURNING * INTO v_attendance_record;
  ELSE
    -- Clock-in
    IF current_time > v_settings.official_start_time THEN
      v_status := 'Late';
    ELSE
      v_status := 'On Time';
    END IF;

    INSERT INTO staff_attendance (staff_id, school_id, check_in_timestamp, status, check_in_location)
    VALUES (auth.uid(), p_school_id, now(), v_status, p_latitude || ',' || p_longitude)
    RETURNING * INTO v_attendance_record;
  END IF;

  RETURN row_to_json(v_attendance_record);
END;
$$;


ALTER FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_attendance_id UUID;
    current_status TEXT;
    v_official_start_time TIME;
    v_official_end_time TIME;
BEGIN
    -- Fetch official start and end times for the school
    SELECT official_start_time, official_end_time
    INTO v_official_start_time, v_official_end_time
    FROM public.school_settings
    WHERE school_id = p_school_id;

    IF p_is_check_in THEN
        -- Check if there's an existing check-in for today without a check-out
        SELECT id, status
        INTO current_attendance_id, current_status
        FROM public.staff_attendance
        WHERE staff_id = p_staff_id
          AND DATE(check_in_timestamp) = CURRENT_DATE
          AND check_out_timestamp IS NULL;

        IF current_attendance_id IS NOT NULL THEN
            -- Already checked in, do nothing or log a warning
            RAISE NOTICE 'Staff member % already checked in for today.', p_staff_id;
        ELSE
            -- Determine status (On Time or Late)
            IF CURRENT_TIME < v_official_start_time THEN
                current_status := 'Present';
            ELSE
                current_status := 'Late';
            END IF;

            -- Insert new check-in record
            INSERT INTO public.staff_attendance (staff_id, school_id, check_in_timestamp, status, check_in_location)
            VALUES (p_staff_id, p_school_id, NOW(), current_status, p_latitude || ',' || p_longitude);
        END IF;
    ELSE
        -- Handle check-out
        SELECT id
        INTO current_attendance_id
        FROM public.staff_attendance
        WHERE staff_id = p_staff_id
          AND DATE(check_in_timestamp) = CURRENT_DATE
          AND check_out_timestamp IS NULL;

        IF current_attendance_id IS NOT NULL THEN
            -- Update existing check-in record with check-out time
            UPDATE public.staff_attendance
            SET check_out_timestamp = NOW()
            WHERE id = current_attendance_id;
        ELSE
            -- No matching check-in to check out from, do nothing or log a warning
            RAISE NOTICE 'Staff member % tried to check out without a prior check-in for today.', p_staff_id;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    INSERT INTO public.attendance (student_id, class_id, date, status, marked_by_teacher_id, created_at, updated_at)
    VALUES (p_student_id, p_class_id, p_date, p_status, p_marked_by_teacher_id, NOW(), NOW())
    ON CONFLICT (student_id, class_id, date) -- This identifies the row to update if it exists
    DO UPDATE SET
        status = EXCLUDED.status, -- EXCLUDED refers to the values from the attempted INSERT
        marked_by_teacher_id = EXCLUDED.marked_by_teacher_id,
        updated_at = NOW(); -- Explicitly set updated_at on update
END;
$$;


ALTER FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    INSERT INTO public.staff_attendance (staff_id, school_id, attendance_date, status, check_in, check_out)
    VALUES (p_staff_id, p_school_id, p_attendance_date, p_status, p_check_in, p_check_out)
    ON CONFLICT (staff_id, attendance_date) DO UPDATE
    SET
        school_id = EXCLUDED.school_id,
        status = EXCLUDED.status,
        check_in = EXCLUDED.check_in,
        check_out = EXCLUDED.check_out,
        updated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.student_exam_marks (exam_id, student_id, subject_id, marks_obtained)
    VALUES (p_exam_id, p_student_id, p_subject_id, p_marks_obtained)
    ON CONFLICT (exam_id, student_id, subject_id) DO UPDATE
    SET marks_obtained = p_marks_obtained, updated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."announcements" (
    "id" integer NOT NULL,
    "school_id" integer NOT NULL,
    "title" "text" NOT NULL,
    "content" "text" NOT NULL,
    "created_by_user_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "target_role" "text",
    "target_class_id" integer,
    CONSTRAINT "announcements_target_role_check" CHECK (("target_role" = ANY (ARRAY['All'::"text", 'Teachers'::"text", 'Parents'::"text", 'SpecificClass'::"text"])))
);


ALTER TABLE "public"."announcements" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."announcements_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."announcements_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."announcements_id_seq" OWNED BY "public"."announcements"."id";



CREATE TABLE IF NOT EXISTS "public"."app_versions" (
    "id" bigint NOT NULL,
    "version_name" "text" NOT NULL,
    "version_code" integer NOT NULL,
    "release_notes" "text",
    "apk_url" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."app_versions" OWNER TO "postgres";


ALTER TABLE "public"."app_versions" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."app_versions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."attendance" (
    "id" integer NOT NULL,
    "student_id" integer NOT NULL,
    "class_id" integer NOT NULL,
    "date" "date" NOT NULL,
    "marked_by_teacher_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'Present'::"text" NOT NULL,
    CONSTRAINT "attendance_status_check" CHECK (("status" = ANY (ARRAY['Present'::"text", 'Absent'::"text", 'Late'::"text", 'Holiday'::"text", 'Leave'::"text"])))
);


ALTER TABLE "public"."attendance" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."attendance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."attendance_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."attendance_id_seq" OWNED BY "public"."attendance"."id";



CREATE TABLE IF NOT EXISTS "public"."classes" (
    "id" integer NOT NULL,
    "school_id" integer NOT NULL,
    "name" "text" NOT NULL,
    "teacher_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "section" "text"
);


ALTER TABLE "public"."classes" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."classes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."classes_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."classes_id_seq" OWNED BY "public"."classes"."id";



CREATE TABLE IF NOT EXISTS "public"."exams" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "school_id" integer,
    "name" "text" NOT NULL,
    "description" "text",
    "exam_date" "date" NOT NULL,
    "max_marks" integer NOT NULL,
    "examiner_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "class_id" integer
);


ALTER TABLE "public"."exams" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."finance_entries" (
    "id" integer NOT NULL,
    "school_id" integer NOT NULL,
    "entry_type" "text" NOT NULL,
    "description" "text" NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "date" "date" NOT NULL,
    "created_by_user_id" "uuid",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "category" "text",
    CONSTRAINT "finance_entries_entry_type_check" CHECK (("entry_type" = ANY (ARRAY['Income'::"text", 'Expense'::"text"])))
);


ALTER TABLE "public"."finance_entries" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."finance_entries_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."finance_entries_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."finance_entries_id_seq" OWNED BY "public"."finance_entries"."id";



CREATE TABLE IF NOT EXISTS "public"."form_fields" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "form_id" "uuid",
    "question" "text" NOT NULL,
    "type" "public"."form_field_type" NOT NULL,
    "options" "text"[],
    "required" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."form_fields" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."form_response_answers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "response_id" "uuid",
    "field_id" "uuid",
    "answer" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."form_response_answers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."form_responses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "form_id" "uuid",
    "student_id" integer,
    "parent_id" "uuid",
    "submitted_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."form_responses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."grades" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "school_id" integer,
    "name" "text" NOT NULL,
    "min_percentage" integer NOT NULL,
    "max_percentage" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."grades" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lesson_plans" (
    "id" integer NOT NULL,
    "class_id" integer NOT NULL,
    "teacher_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "date" "date" NOT NULL,
    "document_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "subject_name" "text" NOT NULL
);


ALTER TABLE "public"."lesson_plans" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."lesson_plans_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."lesson_plans_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."lesson_plans_id_seq" OWNED BY "public"."lesson_plans"."id";



CREATE TABLE IF NOT EXISTS "public"."parent_student_relations" (
    "id" integer NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "student_id" integer NOT NULL,
    "relation_type" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."parent_student_relations" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."parent_student_relations_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."parent_student_relations_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."parent_student_relations_id_seq" OWNED BY "public"."parent_student_relations"."id";



CREATE TABLE IF NOT EXISTS "public"."school_settings" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "school_id" integer NOT NULL,
    "location_latitude" double precision,
    "location_longitude" double precision,
    "attendance_radius_meters" integer,
    "official_start_time" time without time zone,
    "official_end_time" time without time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."school_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."students" (
    "id" integer NOT NULL,
    "school_id" integer NOT NULL,
    "class_id" integer,
    "full_name" "text" NOT NULL,
    "profile_photo_url" "text",
    "date_of_birth" "date",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "gender" "text"
);


ALTER TABLE "public"."students" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."school_students_view" AS
 SELECT "s"."id",
    "s"."full_name",
    "s"."date_of_birth",
    "s"."profile_photo_url",
    "s"."class_id",
    "c"."school_id"
   FROM ("public"."students" "s"
     JOIN "public"."classes" "c" ON (("s"."class_id" = "c"."id")));


ALTER TABLE "public"."school_students_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."schools" (
    "id" integer NOT NULL,
    "name" "text" NOT NULL,
    "logo_url" "text",
    "academic_year" character varying(20),
    "theme" character varying(50),
    "contact_info" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "hijri_day_adjustment" integer
);


ALTER TABLE "public"."schools" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."schools_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."schools_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."schools_id_seq" OWNED BY "public"."schools"."id";



CREATE TABLE IF NOT EXISTS "public"."staff_attendance" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "staff_id" "uuid" NOT NULL,
    "school_id" integer NOT NULL,
    "check_in_timestamp" timestamp with time zone,
    "check_out_timestamp" timestamp with time zone,
    "status" "text",
    "check_in_location" "text",
    "notes" "text"
);


ALTER TABLE "public"."staff_attendance" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_exam_marks" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "student_id" integer,
    "exam_id" "uuid",
    "subject_id" "uuid",
    "marks_obtained" integer NOT NULL,
    "total_marks" integer NOT NULL,
    "grade_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."student_exam_marks" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."students_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."students_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."students_id_seq" OWNED BY "public"."students"."id";



CREATE TABLE IF NOT EXISTS "public"."timetables" (
    "id" integer NOT NULL,
    "class_id" integer NOT NULL,
    "day_of_week" character varying(10) NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    "subject_name" "text" NOT NULL,
    "teacher_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "timetables_day_of_week_check" CHECK ((("day_of_week")::"text" = ANY ((ARRAY['Monday'::character varying, 'Tuesday'::character varying, 'Wednesday'::character varying, 'Thursday'::character varying, 'Friday'::character varying, 'Saturday'::character varying, 'Sunday'::character varying])::"text"[])))
);


ALTER TABLE "public"."timetables" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."timetables_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."timetables_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."timetables_id_seq" OWNED BY "public"."timetables"."id";



CREATE TABLE IF NOT EXISTS "public"."user_settings" (
    "user_id" "uuid" NOT NULL,
    "language" character varying(10) DEFAULT 'English'::character varying,
    "theme" character varying(50) DEFAULT 'green-orange'::character varying,
    "notifications_enabled" boolean DEFAULT true,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "full_name" "text",
    "role" "text" NOT NULL,
    "profile_photo_url" "text",
    "school_id" integer,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "email" character varying,
    CONSTRAINT "users_role_check" CHECK (("role" = ANY (ARRAY['Admin'::"text", 'Teacher'::"text", 'Parent'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."announcements" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."announcements_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."attendance" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."attendance_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."classes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."classes_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."finance_entries" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."finance_entries_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."lesson_plans" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."lesson_plans_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."parent_student_relations" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."parent_student_relations_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."schools" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."schools_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."students" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."students_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."timetables" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."timetables_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."app_versions"
    ADD CONSTRAINT "app_versions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_student_id_class_id_date_key" UNIQUE ("student_id", "class_id", "date");



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."custom_forms"
    ADD CONSTRAINT "custom_forms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exams"
    ADD CONSTRAINT "exams_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."finance_entries"
    ADD CONSTRAINT "finance_entries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_fields"
    ADD CONSTRAINT "form_fields_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_response_answers"
    ADD CONSTRAINT "form_response_answers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."form_responses"
    ADD CONSTRAINT "form_responses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lesson_plans"
    ADD CONSTRAINT "lesson_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."parent_student_relations"
    ADD CONSTRAINT "parent_student_relations_parent_id_student_id_key" UNIQUE ("parent_id", "student_id");



ALTER TABLE ONLY "public"."parent_student_relations"
    ADD CONSTRAINT "parent_student_relations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."school_settings"
    ADD CONSTRAINT "school_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."school_settings"
    ADD CONSTRAINT "school_settings_school_id_key" UNIQUE ("school_id");



ALTER TABLE ONLY "public"."schools"
    ADD CONSTRAINT "schools_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."staff_attendance"
    ADD CONSTRAINT "staff_attendance_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_student_id_exam_id_subject_id_key" UNIQUE ("student_id", "exam_id", "subject_id");



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subjects"
    ADD CONSTRAINT "subjects_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."subjects"
    ADD CONSTRAINT "subjects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."timetables"
    ADD CONSTRAINT "timetables_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_announcements_school_id" ON "public"."announcements" USING "btree" ("school_id");



CREATE INDEX "idx_attendance_class_id" ON "public"."attendance" USING "btree" ("class_id");



CREATE INDEX "idx_attendance_date" ON "public"."attendance" USING "btree" ("date");



CREATE INDEX "idx_attendance_student_id" ON "public"."attendance" USING "btree" ("student_id");



CREATE INDEX "idx_classes_school_id" ON "public"."classes" USING "btree" ("school_id");



CREATE INDEX "idx_classes_teacher_id" ON "public"."classes" USING "btree" ("teacher_id");



CREATE INDEX "idx_finance_entries_school_id" ON "public"."finance_entries" USING "btree" ("school_id");



CREATE INDEX "idx_lesson_plans_class_id" ON "public"."lesson_plans" USING "btree" ("class_id");



CREATE INDEX "idx_lesson_plans_teacher_id" ON "public"."lesson_plans" USING "btree" ("teacher_id");



CREATE INDEX "idx_students_class_id" ON "public"."students" USING "btree" ("class_id");



CREATE INDEX "idx_students_school_id" ON "public"."students" USING "btree" ("school_id");



CREATE INDEX "idx_timetables_class_id" ON "public"."timetables" USING "btree" ("class_id");



CREATE INDEX "idx_users_school_id" ON "public"."users" USING "btree" ("school_id");



CREATE OR REPLACE TRIGGER "set_timestamp_announcements" BEFORE UPDATE ON "public"."announcements" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_attendance" BEFORE UPDATE ON "public"."attendance" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_classes" BEFORE UPDATE ON "public"."classes" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_finance_entries" BEFORE UPDATE ON "public"."finance_entries" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_lesson_plans" BEFORE UPDATE ON "public"."lesson_plans" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_schools" BEFORE UPDATE ON "public"."schools" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_students" BEFORE UPDATE ON "public"."students" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_timetables" BEFORE UPDATE ON "public"."timetables" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_user_settings" BEFORE UPDATE ON "public"."user_settings" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



CREATE OR REPLACE TRIGGER "set_timestamp_users" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_set_timestamp"();



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_target_class_id_fkey" FOREIGN KEY ("target_class_id") REFERENCES "public"."classes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_marked_by_teacher_id_fkey" FOREIGN KEY ("marked_by_teacher_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."attendance"
    ADD CONSTRAINT "attendance_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."classes"
    ADD CONSTRAINT "classes_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."custom_forms"
    ADD CONSTRAINT "custom_forms_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."custom_forms"
    ADD CONSTRAINT "custom_forms_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exams"
    ADD CONSTRAINT "exams_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id");



ALTER TABLE ONLY "public"."exams"
    ADD CONSTRAINT "exams_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."finance_entries"
    ADD CONSTRAINT "finance_entries_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."finance_entries"
    ADD CONSTRAINT "finance_entries_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_fields"
    ADD CONSTRAINT "form_fields_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "public"."custom_forms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_response_answers"
    ADD CONSTRAINT "form_response_answers_field_id_fkey" FOREIGN KEY ("field_id") REFERENCES "public"."form_fields"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_response_answers"
    ADD CONSTRAINT "form_response_answers_response_id_fkey" FOREIGN KEY ("response_id") REFERENCES "public"."form_responses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_responses"
    ADD CONSTRAINT "form_responses_form_id_fkey" FOREIGN KEY ("form_id") REFERENCES "public"."custom_forms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."form_responses"
    ADD CONSTRAINT "form_responses_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."form_responses"
    ADD CONSTRAINT "form_responses_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_plans"
    ADD CONSTRAINT "lesson_plans_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_plans"
    ADD CONSTRAINT "lesson_plans_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."parent_student_relations"
    ADD CONSTRAINT "parent_student_relations_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."parent_student_relations"
    ADD CONSTRAINT "parent_student_relations_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."school_settings"
    ADD CONSTRAINT "school_settings_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."staff_attendance"
    ADD CONSTRAINT "staff_attendance_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id");



ALTER TABLE ONLY "public"."staff_attendance"
    ADD CONSTRAINT "staff_attendance_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "public"."exams"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_grade_id_fkey" FOREIGN KEY ("grade_id") REFERENCES "public"."grades"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_exam_marks"
    ADD CONSTRAINT "student_exam_marks_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "public"."subjects"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subjects"
    ADD CONSTRAINT "subjects_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "public"."schools"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."timetables"
    ADD CONSTRAINT "timetables_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "public"."classes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."timetables"
    ADD CONSTRAINT "timetables_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admins can manage announcements" ON "public"."announcements" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "announcements"."school_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "announcements"."school_id")))));



CREATE POLICY "Admins can manage finance entries for their school" ON "public"."finance_entries" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "finance_entries"."school_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "finance_entries"."school_id")))));



CREATE POLICY "Admins can manage parent-student links" ON "public"."parent_student_relations" USING ("public"."is_admin_of_school"(( SELECT "students"."school_id"
   FROM "public"."students"
  WHERE ("students"."id" = "parent_student_relations"."student_id")))) WITH CHECK ("public"."is_admin_of_school"(( SELECT "students"."school_id"
   FROM "public"."students"
  WHERE ("students"."id" = "parent_student_relations"."student_id"))));



CREATE POLICY "Admins can manage timetables" ON "public"."timetables" USING ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON (("u"."school_id" = "c"."school_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'Admin'::"text") AND ("c"."id" = "timetables"."class_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON (("u"."school_id" = "c"."school_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'Admin'::"text") AND ("c"."id" = "timetables"."class_id")))));



CREATE POLICY "Admins can view all lesson plans in their school" ON "public"."lesson_plans" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON (("u"."school_id" = "c"."school_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("u"."role" = 'Admin'::"text") AND ("c"."id" = "lesson_plans"."class_id")))));



CREATE POLICY "Admins can view other users in their school" ON "public"."users" FOR SELECT TO "authenticated" USING (((( SELECT "users_1"."role"
   FROM "public"."users" "users_1"
  WHERE ("users_1"."id" = "auth"."uid"())) = 'Admin'::"text") AND ("school_id" = ( SELECT "users_1"."school_id"
   FROM "public"."users" "users_1"
  WHERE ("users_1"."id" = "auth"."uid"())))));



CREATE POLICY "Admins can view users in their school (via helper)" ON "public"."users" FOR SELECT TO "authenticated" USING (((( SELECT "users_1"."role"
   FROM "public"."users" "users_1"
  WHERE ("users_1"."id" = "auth"."uid"())) = 'Admin'::"text") AND ("school_id" = "public"."get_admin_school_id"("auth"."uid"()))));



CREATE POLICY "Allow insert access to admins" ON "public"."app_versions" FOR INSERT TO "authenticated" WITH CHECK ((("auth"."jwt"() ->> 'role'::"text") = 'admin'::"text"));



CREATE POLICY "Allow read access to all authenticated users" ON "public"."app_versions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can view schools" ON "public"."schools" FOR SELECT USING (true);



CREATE POLICY "Enable delete for authenticated users" ON "public"."grades" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable delete for authenticated users" ON "public"."student_exam_marks" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable delete for authenticated users" ON "public"."subjects" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."grades" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."student_exam_marks" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."subjects" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable read access for all users" ON "public"."grades" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."student_exam_marks" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."subjects" FOR SELECT USING (true);



CREATE POLICY "Enable update for authenticated users" ON "public"."grades" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable update for authenticated users" ON "public"."student_exam_marks" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable update for authenticated users" ON "public"."subjects" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Parents can view lesson plans for their child's class" ON "public"."lesson_plans" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."students" "s"
     JOIN "public"."parent_student_relations" "psr" ON (("s"."id" = "psr"."student_id")))
  WHERE (("psr"."parent_id" = "auth"."uid"()) AND ("s"."class_id" = "lesson_plans"."class_id")))));



CREATE POLICY "Parents can view their child's attendance" ON "public"."attendance" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."parent_student_relations" "psr"
  WHERE (("psr"."student_id" = "attendance"."student_id") AND ("psr"."parent_id" = "auth"."uid"())))));



CREATE POLICY "Parents can view their linked students" ON "public"."students" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."parent_student_relations" "psr"
  WHERE (("psr"."student_id" = "students"."id") AND ("psr"."parent_id" = "auth"."uid"())))));



CREATE POLICY "Parents can view their own student links" ON "public"."parent_student_relations" FOR SELECT USING (("public"."get_auth_uid"() = "parent_id"));



CREATE POLICY "School admins can insert their school" ON "public"."schools" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text")))));



CREATE POLICY "School admins can update their school" ON "public"."schools" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "schools"."id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text") AND ("users"."school_id" = "schools"."id")))));



CREATE POLICY "School admins/teachers can manage classes" ON "public"."classes" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "classes"."school_id") AND (("users"."role" = 'Admin'::"text") OR ("users"."role" = 'Teacher'::"text")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "classes"."school_id") AND (("users"."role" = 'Admin'::"text") OR ("users"."role" = 'Teacher'::"text"))))));



CREATE POLICY "School admins/teachers can manage students" ON "public"."students" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "students"."school_id") AND (("users"."role" = 'Admin'::"text") OR ("users"."role" = 'Teacher'::"text")))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "students"."school_id") AND (("users"."role" = 'Admin'::"text") OR ("users"."role" = 'Teacher'::"text"))))));



CREATE POLICY "School members can view classes" ON "public"."classes" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "classes"."school_id")))));



CREATE POLICY "School members can view timetables" ON "public"."timetables" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON (("u"."school_id" = "c"."school_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("c"."id" = "timetables"."class_id")))));



CREATE POLICY "Targeted users can view announcements" ON "public"."announcements" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."school_id" = "announcements"."school_id")))) AND (("target_role" = 'All'::"text") OR (("target_role" = 'Teachers'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Teacher'::"text"))))) OR (("target_role" = 'Parents'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Parent'::"text"))))) OR (("target_role" = 'SpecificClass'::"text") AND ("target_class_id" IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM ("public"."students" "s"
     JOIN "public"."parent_student_relations" "psr" ON (("s"."id" = "psr"."student_id")))
  WHERE (("psr"."parent_id" = "auth"."uid"()) AND ("s"."class_id" = "announcements"."target_class_id"))
UNION
 SELECT 1
   FROM "public"."classes" "c"
  WHERE (("c"."teacher_id" = "auth"."uid"()) AND ("c"."id" = "announcements"."target_class_id"))))) OR (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND ("users"."role" = 'Admin'::"text")))))));



CREATE POLICY "Teachers can manage attendance for their classes" ON "public"."attendance" USING ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON ((("u"."id" = "c"."teacher_id") OR ("u"."role" = 'Admin'::"text"))))
  WHERE (("u"."id" = "auth"."uid"()) AND ("c"."id" = "attendance"."class_id") AND ("u"."school_id" = "c"."school_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."users" "u"
     JOIN "public"."classes" "c" ON ((("u"."id" = "c"."teacher_id") OR ("u"."role" = 'Admin'::"text"))))
  WHERE (("u"."id" = "auth"."uid"()) AND ("c"."id" = "attendance"."class_id") AND ("u"."school_id" = "c"."school_id")))));



CREATE POLICY "Teachers can manage their lesson plans" ON "public"."lesson_plans" USING (("auth"."uid"() = "teacher_id")) WITH CHECK (("auth"."uid"() = "teacher_id"));



CREATE POLICY "Users can manage their own settings" ON "public"."user_settings" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own profile" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can update their own data" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can view own profile" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view their own data" ON "public"."users" FOR SELECT USING (("public"."get_auth_uid"() = "id"));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."announcements";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";











































































































































































GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" "uuid", "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_exam"("p_class_id" integer, "p_school_id" integer, "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text", "p_description" "text", "p_max_marks" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_grade"("p_school_id" integer, "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" integer, "p_school_id" integer) TO "service_role";



GRANT ALL ON TABLE "public"."subjects" TO "supabase_admin";
GRANT ALL ON TABLE "public"."subjects" TO "anon";
GRANT ALL ON TABLE "public"."subjects" TO "authenticated";
GRANT ALL ON TABLE "public"."subjects" TO "service_role";



GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_subject"("p_name" "text", "p_class_id" "uuid", "p_school_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text", "academic_year" "text", "theme" "text", "contact_info" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text", "academic_year" "text", "theme" "text", "contact_info" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text", "academic_year" "text", "theme" "text", "contact_info" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_school_and_assign_admin"("school_name" "text", "admin_user_id" "uuid", "logo_url" "text", "academic_year" "text", "theme" "text", "contact_info" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date", "p_profile_photo_url" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date", "p_profile_photo_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date", "p_profile_photo_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_student_and_link_parent"("p_student_name" "text", "p_school_id" integer, "p_class_id" integer, "p_parent_id" "uuid", "p_relation_type" "text", "p_date_of_birth" "date", "p_profile_photo_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_exam"("p_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."delete_exam"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_exam"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_exam"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_grade"("p_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."delete_grade"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_grade"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_grade"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_subject"("p_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."delete_subject"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_subject"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_subject"("p_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."custom_forms" TO "supabase_admin";
GRANT ALL ON TABLE "public"."custom_forms" TO "anon";
GRANT ALL ON TABLE "public"."custom_forms" TO "authenticated";
GRANT ALL ON TABLE "public"."custom_forms" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_active_forms_for_student"("p_student_id" integer, "p_class_ids" integer[], "p_school_id" integer, "p_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_school_id"("user_id_input" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_auth_uid"() TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_auth_uid"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_auth_uid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_auth_uid"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_class_exam_results"("p_class_id" integer, "p_exam_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_class_performance_overview"("p_class_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_school_performance_overview"("p_school_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_student_progress"("p_student_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_student_progress"("p_student_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_student_progress"("p_student_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_student_progress"("p_student_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_student_report_card"("p_student_id" integer, "p_exam_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_subject_performance"("p_school_id" integer, "p_class_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."get_subject_performance"("p_school_id" integer, "p_class_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_subject_performance"("p_school_id" integer, "p_class_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_subject_performance"("p_school_id" integer, "p_class_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_public_user_settings"() TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."handle_new_public_user_settings"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_public_user_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_public_user_settings"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_of_school"("school_id_param" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."is_admin_of_school"("school_id_param" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_of_school"("school_id_param" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_of_school"("school_id_param" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_form_with_answers"("p_form_id" "uuid", "p_student_id" integer, "p_parent_id" "uuid", "p_submitted_by_id" "uuid", "p_answers" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_exam"("p_id" "uuid", "p_class_id" "uuid", "p_name" "text", "p_exam_date" "date", "p_examiner_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_grade"("p_id" "uuid", "p_grade_name" "text", "p_min_percentage" integer, "p_max_percentage" integer, "p_remarks" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_subject"("p_id" "uuid", "p_name" "text", "p_class_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_school_id" "uuid", "p_latitude" double precision, "p_longitude" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_is_check_in" boolean, "p_latitude" double precision, "p_longitude" double precision, "p_school_id" integer, "p_staff_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_student_id" integer, "p_class_id" integer, "p_date" "date", "p_status" "text", "p_marked_by_teacher_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_attendance_record"("p_staff_id" "uuid", "p_school_id" integer, "p_attendance_date" "date", "p_status" character varying, "p_check_in" time without time zone, "p_check_out" time without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) TO "supabase_admin";
GRANT ALL ON FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_student_exam_mark"("p_exam_id" "uuid", "p_student_id" integer, "p_subject_id" "uuid", "p_marks_obtained" integer) TO "service_role";


















GRANT ALL ON TABLE "public"."announcements" TO "supabase_admin";
GRANT ALL ON TABLE "public"."announcements" TO "anon";
GRANT ALL ON TABLE "public"."announcements" TO "authenticated";
GRANT ALL ON TABLE "public"."announcements" TO "service_role";



GRANT ALL ON SEQUENCE "public"."announcements_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."announcements_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."announcements_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."announcements_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."app_versions" TO "supabase_admin";
GRANT ALL ON TABLE "public"."app_versions" TO "anon";
GRANT ALL ON TABLE "public"."app_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."app_versions" TO "service_role";



GRANT ALL ON SEQUENCE "public"."app_versions_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."app_versions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."app_versions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."app_versions_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."attendance" TO "supabase_admin";
GRANT ALL ON TABLE "public"."attendance" TO "anon";
GRANT ALL ON TABLE "public"."attendance" TO "authenticated";
GRANT ALL ON TABLE "public"."attendance" TO "service_role";



GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."attendance_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."classes" TO "supabase_admin";
GRANT ALL ON TABLE "public"."classes" TO "anon";
GRANT ALL ON TABLE "public"."classes" TO "authenticated";
GRANT ALL ON TABLE "public"."classes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."classes_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."classes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."classes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."classes_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."exams" TO "supabase_admin";
GRANT ALL ON TABLE "public"."exams" TO "anon";
GRANT ALL ON TABLE "public"."exams" TO "authenticated";
GRANT ALL ON TABLE "public"."exams" TO "service_role";



GRANT ALL ON TABLE "public"."finance_entries" TO "supabase_admin";
GRANT ALL ON TABLE "public"."finance_entries" TO "anon";
GRANT ALL ON TABLE "public"."finance_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."finance_entries" TO "service_role";



GRANT ALL ON SEQUENCE "public"."finance_entries_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."finance_entries_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."finance_entries_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."finance_entries_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."form_fields" TO "supabase_admin";
GRANT ALL ON TABLE "public"."form_fields" TO "anon";
GRANT ALL ON TABLE "public"."form_fields" TO "authenticated";
GRANT ALL ON TABLE "public"."form_fields" TO "service_role";



GRANT ALL ON TABLE "public"."form_response_answers" TO "supabase_admin";
GRANT ALL ON TABLE "public"."form_response_answers" TO "anon";
GRANT ALL ON TABLE "public"."form_response_answers" TO "authenticated";
GRANT ALL ON TABLE "public"."form_response_answers" TO "service_role";



GRANT ALL ON TABLE "public"."form_responses" TO "supabase_admin";
GRANT ALL ON TABLE "public"."form_responses" TO "anon";
GRANT ALL ON TABLE "public"."form_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."form_responses" TO "service_role";



GRANT ALL ON TABLE "public"."grades" TO "supabase_admin";
GRANT ALL ON TABLE "public"."grades" TO "anon";
GRANT ALL ON TABLE "public"."grades" TO "authenticated";
GRANT ALL ON TABLE "public"."grades" TO "service_role";



GRANT ALL ON TABLE "public"."lesson_plans" TO "supabase_admin";
GRANT ALL ON TABLE "public"."lesson_plans" TO "anon";
GRANT ALL ON TABLE "public"."lesson_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."lesson_plans" TO "service_role";



GRANT ALL ON SEQUENCE "public"."lesson_plans_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."lesson_plans_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."lesson_plans_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."lesson_plans_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."parent_student_relations" TO "supabase_admin";
GRANT ALL ON TABLE "public"."parent_student_relations" TO "anon";
GRANT ALL ON TABLE "public"."parent_student_relations" TO "authenticated";
GRANT ALL ON TABLE "public"."parent_student_relations" TO "service_role";



GRANT ALL ON SEQUENCE "public"."parent_student_relations_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."parent_student_relations_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."parent_student_relations_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."parent_student_relations_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."school_settings" TO "supabase_admin";
GRANT ALL ON TABLE "public"."school_settings" TO "anon";
GRANT ALL ON TABLE "public"."school_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."school_settings" TO "service_role";



GRANT ALL ON TABLE "public"."students" TO "supabase_admin";
GRANT ALL ON TABLE "public"."students" TO "anon";
GRANT ALL ON TABLE "public"."students" TO "authenticated";
GRANT ALL ON TABLE "public"."students" TO "service_role";



GRANT ALL ON TABLE "public"."school_students_view" TO "supabase_admin";
GRANT ALL ON TABLE "public"."school_students_view" TO "anon";
GRANT ALL ON TABLE "public"."school_students_view" TO "authenticated";
GRANT ALL ON TABLE "public"."school_students_view" TO "service_role";



GRANT ALL ON TABLE "public"."schools" TO "supabase_admin";
GRANT ALL ON TABLE "public"."schools" TO "anon";
GRANT ALL ON TABLE "public"."schools" TO "authenticated";
GRANT ALL ON TABLE "public"."schools" TO "service_role";



GRANT ALL ON SEQUENCE "public"."schools_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."schools_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."schools_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."schools_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."staff_attendance" TO "supabase_admin";
GRANT ALL ON TABLE "public"."staff_attendance" TO "anon";
GRANT ALL ON TABLE "public"."staff_attendance" TO "authenticated";
GRANT ALL ON TABLE "public"."staff_attendance" TO "service_role";



GRANT ALL ON TABLE "public"."student_exam_marks" TO "supabase_admin";
GRANT ALL ON TABLE "public"."student_exam_marks" TO "anon";
GRANT ALL ON TABLE "public"."student_exam_marks" TO "authenticated";
GRANT ALL ON TABLE "public"."student_exam_marks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."students_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."students_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."students_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."students_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."timetables" TO "supabase_admin";
GRANT ALL ON TABLE "public"."timetables" TO "anon";
GRANT ALL ON TABLE "public"."timetables" TO "authenticated";
GRANT ALL ON TABLE "public"."timetables" TO "service_role";



GRANT ALL ON SEQUENCE "public"."timetables_id_seq" TO "supabase_admin";
GRANT ALL ON SEQUENCE "public"."timetables_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."timetables_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."timetables_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_settings" TO "supabase_admin";
GRANT ALL ON TABLE "public"."user_settings" TO "anon";
GRANT ALL ON TABLE "public"."user_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."user_settings" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "supabase_admin";
GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "supabase_admin";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "supabase_admin";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "supabase_admin";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
