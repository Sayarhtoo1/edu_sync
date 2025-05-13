-- Enable RLS for all tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO supabase_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO supabase_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO supabase_admin;

-- USERS Table (handled by Supabase Auth, but we might add a public.users table for profile data)
-- Supabase Auth automatically creates an auth.users table.
-- We'll create a public.users table to store public profile information and link it to auth.users.
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'Teacher', 'Parent')), -- Role of the user
    profile_photo_url TEXT, -- URL to profile photo in Supabase Storage
    school_id INT, -- Foreign key to schools table, nullable if a user can exist without a school initially
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS policy for users: Users can view their own data. Admins can view all users in their school.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own data"
ON public.users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
ON public.users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- SCHOOLS Table
CREATE TABLE public.schools (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    logo_url TEXT, -- URL to school logo in Supabase Storage
    academic_year VARCHAR(20),
    theme VARCHAR(50), -- e.g., 'green-orange'
    contact_info TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS policy for schools: Authenticated users can view schools. School admins can manage their school.
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view schools"
ON public.schools FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "School admins can insert their school"
ON public.schools FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin'));

CREATE POLICY "School admins can update their school"
ON public.schools FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.schools.id))
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.schools.id));

-- Add school_id to users table after schools table is created, if not added before
-- ALTER TABLE public.users ADD COLUMN school_id INT REFERENCES public.schools(id) ON DELETE SET NULL;

-- Function to create a user profile when a new auth.users entry is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, role) -- Default role or based on sign-up data
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'role', 'Parent')); -- Default to 'Parent' if no role specified
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call handle_new_user on new user sign-up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- CLASSES Table
CREATE TABLE public.classes (
    id SERIAL PRIMARY KEY,
    school_id INT NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE SET NULL, -- Teacher assigned to the class
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: School members can view classes. Admins/teachers of the school can manage.
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "School members can view classes"
ON public.classes FOR SELECT
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.classes.school_id));

CREATE POLICY "School admins/teachers can manage classes"
ON public.classes FOR ALL
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.classes.school_id AND (users.role = 'Admin' OR users.role = 'Teacher')))
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.classes.school_id AND (users.role = 'Admin' OR users.role = 'Teacher')));


-- STUDENTS Table (Assuming students are not users of the app directly)
CREATE TABLE public.students (
    id SERIAL PRIMARY KEY,
    school_id INT NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    class_id INT REFERENCES public.classes(id) ON DELETE SET NULL, -- Class the student belongs to
    full_name TEXT NOT NULL,
    profile_photo_url TEXT,
    date_of_birth DATE,
    -- other student-specific details
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: School members can view students. Admins/teachers can manage. Parents can view their children.
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "School admins/teachers can manage students"
ON public.students FOR ALL
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.students.school_id AND (users.role = 'Admin' OR users.role = 'Teacher')))
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.students.school_id AND (users.role = 'Admin' OR users.role = 'Teacher')));

-- PARENT_STUDENT_RELATIONS Table (Many-to-Many or Many-to-One if a student has one primary parent contact in app)
CREATE TABLE public.parent_student_relations (
    id SERIAL PRIMARY KEY,
    parent_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    student_id INT NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    relation_type TEXT, -- e.g., 'Father', 'Mother', 'Guardian'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (parent_id, student_id) -- Ensure a parent is linked to a student only once
);
-- RLS: Involved parent can see the relation. Admin can manage.
ALTER TABLE public.parent_student_relations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can view their own student links"
ON public.parent_student_relations FOR SELECT
USING (auth.uid() = parent_id);

CREATE POLICY "Admins can manage parent-student links"
ON public.parent_student_relations FOR ALL
USING (EXISTS (SELECT 1 FROM public.users u JOIN public.students s ON u.school_id = s.school_id WHERE u.id = auth.uid() AND u.role = 'Admin' AND s.id = student_id));


CREATE POLICY "Parents can view their linked students"
ON public.students FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.parent_student_relations psr
    WHERE psr.student_id = public.students.id AND psr.parent_id = auth.uid()
));


-- ATTENDANCE Table
CREATE TABLE public.attendance (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    class_id INT NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Present', 'Absent', 'Late', 'Holiday')) DEFAULT 'Present', -- Added status column
    marked_by_teacher_id UUID REFERENCES public.users(id) ON DELETE SET NULL, -- Teacher who marked attendance
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (student_id, class_id, date) -- Ensure one attendance record per student per class per day
);
-- RLS: Teachers can manage attendance for their classes. Parents can view their child's. Admins can view all.
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage attendance for their classes"
ON public.attendance FOR ALL
USING (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.id = c.teacher_id OR u.role = 'Admin' -- Admin or assigned teacher
    WHERE u.id = auth.uid() AND c.id = public.attendance.class_id AND u.school_id = c.school_id
))
WITH CHECK (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.id = c.teacher_id OR u.role = 'Admin'
    WHERE u.id = auth.uid() AND c.id = public.attendance.class_id AND u.school_id = c.school_id
));

CREATE POLICY "Parents can view their child's attendance"
ON public.attendance FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.parent_student_relations psr
    WHERE psr.student_id = public.attendance.student_id AND psr.parent_id = auth.uid()
));


-- LESSON_PLANS Table
CREATE TABLE public.lesson_plans (
    id SERIAL PRIMARY KEY,
    class_id INT NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE, -- Teacher who created it
    subject_name TEXT NOT NULL, -- Added subject_name field
    title TEXT NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    document_url TEXT, -- URL to lesson plan document in Supabase Storage
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: Teachers can manage their lesson plans. Admins can view all. Parents of students in class can view.
ALTER TABLE public.lesson_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teachers can manage their lesson plans"
ON public.lesson_plans FOR ALL
USING (auth.uid() = teacher_id)
WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Admins can view all lesson plans in their school"
ON public.lesson_plans FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.school_id = c.school_id
    WHERE u.id = auth.uid() AND u.role = 'Admin' AND c.id = public.lesson_plans.class_id
));

CREATE POLICY "Parents can view lesson plans for their child's class"
ON public.lesson_plans FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.students s
    JOIN public.parent_student_relations psr ON s.id = psr.student_id
    WHERE psr.parent_id = auth.uid() AND s.class_id = public.lesson_plans.class_id
));


-- TIMETABLES Table
CREATE TABLE public.timetables (
    id SERIAL PRIMARY KEY,
    class_id INT NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')), -- e.g., Monday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    subject_name TEXT NOT NULL,
    teacher_id UUID REFERENCES public.users(id) ON DELETE SET NULL, -- Teacher for this specific period
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: School members can view. Admins can manage.
ALTER TABLE public.timetables ENABLE ROW LEVEL SECURITY;

CREATE POLICY "School members can view timetables"
ON public.timetables FOR SELECT
USING (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.school_id = c.school_id
    WHERE u.id = auth.uid() AND c.id = public.timetables.class_id
));

CREATE POLICY "Admins can manage timetables"
ON public.timetables FOR ALL
USING (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.school_id = c.school_id
    WHERE u.id = auth.uid() AND u.role = 'Admin' AND c.id = public.timetables.class_id
))
WITH CHECK (EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.classes c ON u.school_id = c.school_id
    WHERE u.id = auth.uid() AND u.role = 'Admin' AND c.id = public.timetables.class_id
));


-- FINANCE (Income/Expense) Table
CREATE TABLE public.finance_entries (
    id SERIAL PRIMARY KEY,
    school_id INT NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    entry_type TEXT NOT NULL CHECK (entry_type IN ('Income', 'Expense')),
    description TEXT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    created_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: Admins can manage finance entries for their school.
ALTER TABLE public.finance_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage finance entries for their school"
ON public.finance_entries FOR ALL
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.finance_entries.school_id))
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.finance_entries.school_id));


-- APP_SETTINGS Table (can be user-specific or school-specific)
-- For user-specific settings:
CREATE TABLE public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    language VARCHAR(10) DEFAULT 'English', -- 'English' or 'Myanmar'
    theme VARCHAR(50) DEFAULT 'green-orange',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- RLS: Users can manage their own settings.
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own settings"
ON public.user_settings FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Function to create user_settings when a new public.users entry is created
CREATE OR REPLACE FUNCTION public.handle_new_public_user_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_settings (user_id)
  VALUES (new.id);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call handle_new_public_user_settings
CREATE TRIGGER on_public_user_created_create_settings
  AFTER INSERT ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_public_user_settings();


-- ANNOUNCEMENTS Table
CREATE TABLE public.announcements (
    id SERIAL PRIMARY KEY,
    school_id INT NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    target_role TEXT CHECK (target_role IN ('All', 'Teachers', 'Parents', 'SpecificClass')), -- Or more granular
    target_class_id INT REFERENCES public.classes(id) ON DELETE SET NULL -- if target_role is 'SpecificClass'
);
-- RLS: Admins can create. Targeted roles/classes can view.
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage announcements"
ON public.announcements FOR ALL
USING (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.announcements.school_id))
WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Admin' AND users.school_id = public.announcements.school_id));

CREATE POLICY "Targeted users can view announcements"
ON public.announcements FOR SELECT
USING (
    EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.school_id = public.announcements.school_id) AND
    (
        target_role = 'All' OR
        (target_role = 'Teachers' AND EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Teacher')) OR
        (target_role = 'Parents' AND EXISTS (SELECT 1 FROM public.users WHERE users.id = auth.uid() AND users.role = 'Parent')) OR
        (target_role = 'SpecificClass' AND target_class_id IS NOT NULL AND EXISTS (
            -- Parent of student in target class
            SELECT 1 FROM public.students s
            JOIN public.parent_student_relations psr ON s.id = psr.student_id
            WHERE psr.parent_id = auth.uid() AND s.class_id = public.announcements.target_class_id
            UNION
            -- Teacher of target class
            SELECT 1 FROM public.classes c
            WHERE c.teacher_id = auth.uid() AND c.id = public.announcements.target_class_id
        ))
    )
);


-- STORAGE BUCKETS (To be created via Supabase Dashboard or CLI)
-- 1. edusync (public: false, or with appropriate RLS for profile photos, logos, lesson plans)
--    - schools/<school_id>.<file_extension> (for school logos)
--    - users/profile_photos/<user_id>.<file_extension> (for user profile photos)
--    - students/profile_photos/<student_id>.<file_extension> (for student profile photos)
--    - lessonplans/<teacher_id>/<timestamp>.<file_extension> (for lesson plan documents)

-- Example RLS for a storage bucket (e.g., 'user_profile_photos')
-- This is illustrative; actual RLS for storage is configured differently in Supabase.
-- For 'edusync' bucket, with path 'users/profile_photos/<user_id>.jpg':
-- Users can upload their own profile photo:
-- (bucket_id = 'edusync' AND name = <user_id>.jpg AND auth.uid()::text = split_part(name, '.', 1))
-- Users can view their own profile photo:
-- (bucket_id = 'edusync' AND name = <user_id>.jpg AND auth.uid()::text = split_part(name, '.', 1))
-- Or make it public if profile photos are generally viewable by authenticated users.

-- Ensure to set up foreign key from public.users.school_id to public.schools.id
-- This might need to be done after both tables are created if there's a circular dependency concern
-- or if users can be created before schools (e.g. a superadmin).
-- For this app, an admin registers a school, so school_id in users should reference an existing school.
-- The current public.users table has school_id, ensure it's correctly linked.
-- If an admin creates their user and school simultaneously, the school_id for the admin user
-- needs to be updated after the school is created.

-- Consider adding indexes for frequently queried columns, e.g., foreign keys, dates, roles.
CREATE INDEX idx_users_school_id ON public.users(school_id);
CREATE INDEX idx_classes_school_id ON public.classes(school_id);
CREATE INDEX idx_classes_teacher_id ON public.classes(teacher_id);
CREATE INDEX idx_students_school_id ON public.students(school_id);
CREATE INDEX idx_students_class_id ON public.students(class_id);
CREATE INDEX idx_attendance_student_id ON public.attendance(student_id);
CREATE INDEX idx_attendance_class_id ON public.attendance(class_id);
CREATE INDEX idx_attendance_date ON public.attendance(date);
CREATE INDEX idx_lesson_plans_class_id ON public.lesson_plans(class_id);
CREATE INDEX idx_lesson_plans_teacher_id ON public.lesson_plans(teacher_id);
CREATE INDEX idx_timetables_class_id ON public.timetables(class_id);
CREATE INDEX idx_finance_entries_school_id ON public.finance_entries(school_id);
CREATE INDEX idx_announcements_school_id ON public.announcements(school_id);

-- Function to update `updated_at` columns automatically
CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to all tables with an `updated_at` column
CREATE TRIGGER set_timestamp_users
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_schools
BEFORE UPDATE ON public.schools
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_classes
BEFORE UPDATE ON public.classes
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_students
BEFORE UPDATE ON public.students
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_attendance
BEFORE UPDATE ON public.attendance
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_lesson_plans
BEFORE UPDATE ON public.lesson_plans
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_timetables
BEFORE UPDATE ON public.timetables
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_finance_entries
BEFORE UPDATE ON public.finance_entries
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_user_settings
BEFORE UPDATE ON public.user_settings
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();

CREATE TRIGGER set_timestamp_announcements
BEFORE UPDATE ON public.announcements
FOR EACH ROW
EXECUTE FUNCTION public.trigger_set_timestamp();
