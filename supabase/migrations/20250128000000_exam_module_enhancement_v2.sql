-- Migration: exam_module_enhancement_v2
-- Description: Enhance exam module with multi-class support, sub-subjects, and advanced features
-- Date: 2025-01-28

BEGIN;

-- 1. Create exam_classes table for multi-class exam support
CREATE TABLE IF NOT EXISTS exam_classes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  exam_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  venue TEXT,
  instructions TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(exam_id, class_id)
);

CREATE INDEX idx_exam_classes_exam ON exam_classes(exam_id);
CREATE INDEX idx_exam_classes_class ON exam_classes(class_id);

-- 2. Migrate existing exam data to exam_classes
INSERT INTO exam_classes (exam_id, class_id, exam_date)
SELECT id, class_id, exam_date
FROM exams
WHERE class_id IS NOT NULL AND exam_date IS NOT NULL;

-- 3. Modify exams table - remove single class/date, add exam type
ALTER TABLE exams DROP COLUMN IF EXISTS class_id;
ALTER TABLE exams DROP COLUMN IF EXISTS exam_date;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS exam_type TEXT CHECK (exam_type IN ('Midterm', 'Final', 'Quiz', 'Monthly', 'Unit Test', 'Other'));

-- 4. Enhance subjects table for parent-child relationships (sub-subjects)
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS parent_subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE;
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS is_sub_subject BOOLEAN DEFAULT FALSE;
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_subjects_parent ON subjects(parent_subject_id);

-- 5. Enhance exam_subjects table with examiner, distinction, optional, weightage
ALTER TABLE exam_subjects ADD COLUMN IF NOT EXISTS examiner_id UUID REFERENCES users(id);
ALTER TABLE exam_subjects ADD COLUMN IF NOT EXISTS distinction_marks INTEGER;
ALTER TABLE exam_subjects ADD COLUMN IF NOT EXISTS is_optional BOOLEAN DEFAULT FALSE;
ALTER TABLE exam_subjects ADD COLUMN IF NOT EXISTS weightage DECIMAL(5,2) DEFAULT 100.00;

COMMIT;
