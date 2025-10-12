-- Create exam_templates table
CREATE TABLE IF NOT EXISTS exam_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id INTEGER REFERENCES schools(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  subjects JSONB NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_exam_templates_school_id ON exam_templates(school_id);
