CREATE OR REPLACE VIEW school_students_view AS
SELECT
  s.id,
  c.name,
  s.date_of_birth,
  s.profile_photo_url,
  s.class_id,
  c.school_id
FROM
  students s
JOIN
  classes c ON s.class_id = c.id;