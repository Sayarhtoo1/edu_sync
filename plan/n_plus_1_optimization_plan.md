# N+1 Query Optimization Plan

## 1. Problem Analysis

The current implementation of `getStudentsBySchool` in `lib/services/student_service.dart` suffers from the N+1 query problem. It first fetches all classes for a given school (1 query) and then iterates through each class to fetch its students (N queries), where N is the number of classes. This is inefficient and can lead to significant performance degradation as the number of classes grows.

**Problematic Code (`lib/services/student_service.dart`):**
```dart
Future<List<Student>> getStudentsBySchool(int schoolId) async {
  final List<Student> allStudents = [];
  final classes = await _classService.getClasses(schoolId); // 1st Query
  for (final c in classes) {
    if (c.id != null) {
      final students = await getStudentsByClass(c.id!); // N queries
      allStudents.addAll(students);
    }
  }
  return allStudents;
}
```

## 2. Proposed Solution: Database View

A **Database View** is the optimal solution for this problem. A view will pre-join the `classes` and `students` tables, allowing us to fetch all students for a school in a single query.

**Justification:**
- **Efficiency:** A view reduces multiple round-trips to the database into a single, efficient query.
- **Simplicity:** It avoids the need for a more complex RPC function since the operation is a straightforward read query.
- **Maintainability:** The data fetching logic is encapsulated within the database, making the client-side code cleaner and easier to maintain.

## 3. SQL Definition

The following SQL statement will create a view named `school_students_view` that joins `students` with `classes` to include `school_id`.

```sql
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
```

## 4. Client-Side Refactoring Plan

The client-side code in `lib/services/student_service.dart` must be refactored to use the new `school_students_view`.

**File to Modify:** `lib/services/student_service.dart`

**Method to Refactor:** `getStudentsBySchool`

**Refactored Code:**
```dart
// In lib/services/student_service.dart

// Fetch all students for a school using the new view
Future<List<Student>> getStudentsBySchool(int schoolId) async {
  try {
    final response = await _supabaseClient
        .from('school_students_view')
        .select()
        .eq('school_id', schoolId);

    final students = response.map((data) => Student.fromMap(data)).toList();
    return students;
  } catch (e) {
    print('Error fetching students by school: $e');
    return [];
  }
}
```

This updated implementation replaces the multiple queries with a single call to the `school_students_view`, resolving the N+1 problem.