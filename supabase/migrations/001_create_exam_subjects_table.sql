-- Create the missing exam_subjects table
-- This table is referenced in multiple functions but doesn't exist

CREATE TABLE IF NOT EXISTS "public"."exam_subjects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "exam_id" "uuid" NOT NULL,
    "subject_id" "uuid" NOT NULL,
    "max_marks" integer NOT NULL,
    "passing_marks" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "exam_subjects_exam_id_subject_id_key" UNIQUE ("exam_id", "subject_id")
);

ALTER TABLE "public"."exam_subjects" OWNER TO "postgres";

-- Add foreign key constraints
ALTER TABLE "public"."exam_subjects"
    ADD CONSTRAINT "exam_subjects_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "public"."exams"("id") ON DELETE CASCADE;

ALTER TABLE "public"."exam_subjects"
    ADD CONSTRAINT "exam_subjects_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "public"."subjects"("id") ON DELETE CASCADE;

-- Add primary key constraint
ALTER TABLE ONLY "public"."exam_subjects"
    ADD CONSTRAINT "exam_subjects_pkey" PRIMARY KEY ("id");

-- Create indexes for better performance
CREATE INDEX "idx_exam_subjects_exam_id" ON "public"."exam_subjects" USING "btree" ("exam_id");
CREATE INDEX "idx_exam_subjects_subject_id" ON "public"."exam_subjects" USING "btree" ("subject_id");

-- Enable RLS
ALTER TABLE "public"."exam_subjects" ENABLE ROW LEVEL SECURITY;

-- Add RLS policies for proper access control
CREATE POLICY "School admins/teachers can manage exam subjects" ON "public"."exam_subjects"
    USING (
        EXISTS (
            SELECT 1 FROM "public"."exams" e
            JOIN "public"."users" u ON u."school_id" = e."school_id"
            WHERE e."id" = "exam_subjects"."exam_id"
            AND u."id" = "auth"."uid"()
            AND (u."role" = 'Admin' OR u."role" = 'Teacher')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "public"."exams" e
            JOIN "public"."users" u ON u."school_id" = e."school_id"
            WHERE e."id" = "exam_subjects"."exam_id"
            AND u."id" = "auth"."uid"()
            AND (u."role" = 'Admin' OR u."role" = 'Teacher')
        )
    );

-- Grant permissions
GRANT ALL ON TABLE "public"."exam_subjects" TO "supabase_admin";
GRANT ALL ON TABLE "public"."exam_subjects" TO "anon";
GRANT ALL ON TABLE "public"."exam_subjects" TO "authenticated";
GRANT ALL ON TABLE "public"."exam_subjects" TO "service_role";