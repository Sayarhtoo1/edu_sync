# Database Migrations - Exam Module Fixes

This directory contains database migrations to fix critical backend issues in the exam module.

## Issues Fixed

### 1. ✅ Created missing exam_subjects table
- **File**: `001_create_exam_subjects_table.sql`
- **Issue**: The `exam_subjects` table was referenced in 7+ functions but didn't exist
- **Solution**: Created the table with proper structure including:
  - `id` (UUID, Primary Key)
  - `exam_id` (UUID, Foreign Key to exams)
  - `subject_id` (UUID, Foreign Key to subjects)
  - `max_marks` (integer)
  - `passing_marks` (integer)
  - `created_at`, `updated_at` timestamps
  - Unique constraint on (exam_id, subject_id)
  - Proper indexes and RLS policies

### 2. ✅ Fixed conflicting add_exam functions
- **File**: `002_fix_exam_functions_and_constraints.sql` and `004_fix_data_type_inconsistencies.sql`
- **Issue**: Two different function signatures existed:
  - `add_exam(uuid, integer, text, date, text)` - returned UUID
  - `add_exam(integer, integer, text, date, text, text, integer)` - returned void
- **Solution**: Unified into single consistent function with signature:
  - `add_exam(integer, integer, text, date, text, text, integer)` - returns UUID
  - Includes optional description and max_marks parameters
  - Updated corresponding update_exam function

### 3. ✅ Added missing foreign key constraints
- **File**: `002_fix_exam_functions_and_constraints.sql` and `004_fix_data_type_inconsistencies.sql`
- **Issue**: Missing FK constraint for `exams.class_id`
- **Solution**: Added proper foreign key constraint:
  - `exams.class_id` → `classes.id` (integer)

### 4. ✅ Implemented missing functions
- **File**: `003_add_missing_functions.sql`
- **Issue**: Frontend services expected these functions that didn't exist
- **Solution**: Implemented three missing functions:

#### `upsert_exam_subject`
```sql
upsert_exam_subject(
    p_exam_id uuid,
    p_subject_id uuid,
    p_max_marks integer,
    p_passing_marks integer
) RETURNS uuid
```
- Inserts or updates exam subject configuration
- Handles conflicts with ON CONFLICT clause

#### `get_detailed_student_report_card`
```sql
get_detailed_student_report_card(
    p_student_id integer,
    p_exam_id uuid
) RETURNS TABLE(...)
```
- Returns comprehensive student report card
- Includes subject-wise marks, grades, percentages, and pass/fail status

#### `get_student_performance`
```sql
get_student_performance(
    p_student_id integer,
    p_academic_year text DEFAULT NULL
) RETURNS TABLE(...)
```
- Returns student performance across all exams
- Includes rankings, overall percentages, and trends

### 5. ✅ Fixed data type inconsistencies
- **File**: `004_fix_data_type_inconsistencies.sql`
- **Issue**: `exams.class_id` was incorrectly changed to UUID when it should be integer to match `classes.id`
- **Solution**: Corrected data type back to integer with proper foreign key constraint

### 6. ✅ Created missing seed.sql file
- **File**: `supabase/seed.sql`
- **Issue**: `config.toml` referenced `./seed.sql` but file didn't exist
- **Solution**: Created comprehensive seed file with:
  - Sample schools data
  - Grade configurations for all schools
  - Subject definitions
  - School settings (location, attendance radius, official times)

## How to Apply These Migrations

1. **Option 1 - Using Supabase CLI**:
   ```bash
   # Apply migrations in order
   supabase db push --file supabase/migrations/001_create_exam_subjects_table.sql
   supabase db push --file supabase/migrations/002_fix_exam_functions_and_constraints.sql
   supabase db push --file supabase/migrations/003_add_missing_functions.sql
   supabase db push --file supabase/migrations/004_fix_data_type_inconsistencies.sql

   # Reset database with seed data
   supabase db reset
   ```

2. **Option 2 - Manual Application**:
   - Execute each migration file in numerical order against your database
   - The migrations are designed to be idempotent (can be run multiple times safely)

## Database Design Principles Followed

- ✅ **Referential Integrity**: All foreign key constraints properly defined
- ✅ **Data Consistency**: Unified function signatures and data types
- ✅ **Performance**: Proper indexes on frequently queried columns
- ✅ **Security**: Row Level Security (RLS) policies implemented
- ✅ **Scalability**: UUID primary keys where appropriate, integer for high-volume tables
- ✅ **Error Handling**: Functions include proper error handling and validation

## Testing Recommendations

1. Test all CRUD operations for exams and exam_subjects
2. Verify that existing functions still work with the schema changes
3. Test the new functions with sample data
4. Verify foreign key constraints prevent invalid data
5. Test RLS policies work correctly for different user roles

## Notes

- All functions are granted proper permissions for anon, authenticated, and service_role
- The migrations maintain backward compatibility where possible
- The seed data provides a foundation for testing and development
- Database triggers and policies are preserved and enhanced