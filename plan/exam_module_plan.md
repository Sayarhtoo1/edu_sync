# Final Exam Module Implementation Plan

This document outlines the plan for implementing the exam module in the EduSync project.

## 1. Database Schema (Supabase)

- **`subjects`**
  - `id` (uuid, primary key, default: `gen_random_uuid()`)
  - `name` (text)
  - `class_id` (integer, foreign key to `classes.id`)
  - `school_id` (integer, foreign key to `schools.id`)
  - `created_at` (timestamp with time zone, default: `now()`)

- **`exams`**
  - `id` (uuid, primary key, default: `gen_random_uuid()`)
  - `class_id` (integer, foreign key to `classes.id`)
  - `school_id` (integer, foreign key to `schools.id`)
  - `name` (text, e.g., "Midterm Exam", "Final Exam")
  - `exam_date` (date)
  - `examiner_name` (text)
  - `created_at` (timestamp with time zone, default: `now()`)

- **`student_exam_marks`**
  - `id` (uuid, primary key, default: `gen_random_uuid()`)
  - `exam_id` (uuid, foreign key to `exams.id`)
  - `student_id` (integer, foreign key to `students.id`)
  - `subject_id` (uuid, foreign key to `subjects.id`)
  - `marks_obtained` (integer)
  - `created_at` (timestamp with time zone, default: `now()`)

- **`grades`**
  - `id` (uuid, primary key, default: `gen_random_uuid()`)
  - `school_id` (integer, foreign key to `schools.id`)
  - `grade_name` (text, e.g., "A", "B", "C")
  - `min_percentage` (integer)
  - `max_percentage` (integer)
  - `remarks` (text)
  - `created_at` (timestamp with time zone, default: `now()`)

## 2. API Endpoints (Supabase RPC)

- `create_exam(class_id, school_id, name, exam_date, examiner_name)`
- `add_subject(name, class_id, school_id)`
- `add_grade(school_id, grade_name, min_percentage, max_percentage, remarks)`
- `input_student_marks(exam_id, student_id, subject_id, marks_obtained)`
- `get_student_report_card(student_id, exam_id)`
- `get_class_exam_results(class_id, exam_id)`

## 3. Frontend Implementation (Flutter)

- **Models (`lib/models/`)**
  - `subject.dart`
  - `exam.dart`
  - `student_exam_mark.dart`
  - `grade.dart`

- **Services (`lib/services/`)**
  - `exam_service.dart`

- **Providers (`lib/providers/`)**
  - `exam_provider.dart`

- **Screens (`lib/screens/`)**
  - **Admin Role:**
    - `exam_management_screen.dart`
    - `subject_management_screen.dart`
    - `grade_management_screen.dart`
    - `add_edit_exam_screen.dart`
  - **Teacher Role:**
    - `input_marks_screen.dart`
  - **Student/Parent Role:**
    - `report_card_screen.dart`
