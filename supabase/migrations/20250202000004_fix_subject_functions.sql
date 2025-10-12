-- Ensure update_subject function exists and works correctly
CREATE OR REPLACE FUNCTION update_subject(
  p_subject_id UUID,
  p_name TEXT,
  p_school_id INTEGER,
  p_class_id INTEGER DEFAULT NULL,
  p_code TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE subjects
  SET 
    name = p_name,
    school_id = p_school_id,
    class_id = p_class_id,
    code = p_code
  WHERE id = p_subject_id;
END;
$$ LANGUAGE plpgsql;

-- Ensure delete_subject function exists and works correctly
CREATE OR REPLACE FUNCTION delete_subject(p_subject_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM subjects WHERE id = p_subject_id;
END;
$$ LANGUAGE plpgsql;
