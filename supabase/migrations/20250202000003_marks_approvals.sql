-- Create marks_approvals table
CREATE TABLE IF NOT EXISTS marks_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
  submitted_by UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  comments TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_marks_approvals_exam_id ON marks_approvals(exam_id);
CREATE INDEX IF NOT EXISTS idx_marks_approvals_status ON marks_approvals(status);
CREATE INDEX IF NOT EXISTS idx_marks_approvals_submitted_by ON marks_approvals(submitted_by);
