-- Migration: Exam Module Constraints and Indexes
-- Description: Add constraints and indexes to improve exam module data integrity and performance
-- Date: 2025-02-02

-- 1. Make class_id mandatory in exams table (exams must be associated with a class)
-- Note: First update any existing NULL values to a default class
DO $$
BEGIN
  -- Only alter if column exists and is nullable
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'exams' AND column_name = 'class_id' AND is_nullable = 'YES'
  ) THEN
    -- Update NULL values if any exist (set to first available class)
    UPDATE exams 
    SET class_id = (SELECT id FROM classes LIMIT 1)
    WHERE class_id IS NULL;
    
    -- Make column NOT NULL
    ALTER TABLE exams ALTER COLUMN class_id SET NOT NULL;
  END IF;
END $$;

-- 2. Add constraint to validate marks range in student_exam_marks
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_marks_range'
  ) THEN
    ALTER TABLE student_exam_marks
      ADD CONSTRAINT chk_marks_range 
      CHECK (marks_obtained >= 0 AND marks_obtained <= total_marks);
  END IF;
END $$;

-- 3. Add performance indexes for exam queries

-- Index for fetching exams by school and date (most common query)
CREATE INDEX IF NOT EXISTS idx_exams_school_date 
  ON exams(school_id, exam_date DESC);

-- Index for fetching exams by class and date
CREATE INDEX IF NOT EXISTS idx_exams_class_date 
  ON exams(class_id, exam_date DESC);

-- Index for fetching student marks by exam (for report cards)
CREATE INDEX IF NOT EXISTS idx_student_marks_exam_student 
  ON student_exam_marks(exam_id, student_id);

-- Index for fetching marks by subject (for subject-wise analysis)
CREATE INDEX IF NOT EXISTS idx_student_marks_subject 
  ON student_exam_marks(subject_id);

-- Composite index for marks lookup by exam and subject
CREATE INDEX IF NOT EXISTS idx_student_marks_exam_subject 
  ON student_exam_marks(exam_id, subject_id);

-- Index for exam subjects lookup
CREATE INDEX IF NOT EXISTS idx_exam_subjects_exam 
  ON exam_subjects(exam_id);

-- Index for subjects by school (for dropdown filters)
CREATE INDEX IF NOT EXISTS idx_subjects_school 
  ON subjects(school_id, name);

-- Index for subjects by class (for class-specific subjects)
CREATE INDEX IF NOT EXISTS idx_subjects_class 
  ON subjects(class_id) WHERE class_id IS NOT NULL;

-- Index for grades by school (for grade calculation)
CREATE INDEX IF NOT EXISTS idx_grades_school_percentage 
  ON grades(school_id, min_percentage DESC);

-- 4. Add helpful comments
COMMENT ON CONSTRAINT chk_marks_range ON student_exam_marks IS 
  'Ensures marks obtained are within valid range (0 to total_marks)';

COMMENT ON INDEX idx_exams_school_date IS 
  'Optimizes queries fetching exams by school ordered by date';

COMMENT ON INDEX idx_student_marks_exam_student IS 
  'Optimizes report card generation queries';
