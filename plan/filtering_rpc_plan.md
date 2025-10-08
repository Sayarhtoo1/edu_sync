# RPC Function Design for Complex Filtering

**Objective:** To improve performance and reduce client-side complexity by moving the filtering logic for `getActiveFormsForStudent` from the Dart client to a Supabase RPC function.

## 1. Analysis of Client-Side Filtering

The current implementation in `lib/services/custom_form_service.dart` in the `getActiveFormsForStudent` function fetches a broad set of forms from the database and then performs complex filtering in Dart.

**File:** [`lib/services/custom_form_service.dart`](lib/services/custom_form_service.dart:98)

**Current Logic:**
1.  Fetches all forms from the `custom_forms` table that belong to the student's `school_id` and are active within the given date range (`active_from` and `active_to`).
2.  Iterates through the fetched forms in Dart.
3.  For each form, it checks three conditions:
    *   If the form is assigned to the whole school (`assign_to_whole_school` is true).
    *   If the student's ID is present in the `assigned_student_ids` list.
    *   If any of the student's `classIds` are present in the `assigned_class_ids` list.
4.  A final list of unique forms is compiled and returned.

This approach is inefficient as it transfers unnecessary data and puts a heavy processing load on the client device.

## 2. Proposed Supabase RPC Function

A new PostgreSQL function, `get_active_forms_for_student`, will be created to handle all filtering on the server side.

### SQL Function Definition

```sql
create or replace function get_active_forms_for_student(
    p_student_id int,
    p_class_ids int[],
    p_school_id int,
    p_date date
)
returns setof custom_forms as $$
begin
    return query
    select *
    from custom_forms
    where
        school_id = p_school_id and
        active_from <= p_date and
        active_to >= p_date and
        (
            assign_to_whole_school = true or
            assigned_student_ids @> array[p_student_id] or
            assigned_class_ids && p_class_ids
        );
end;
$$ language plpgsql;
```

**Parameters:**
*   `p_student_id` (integer): The ID of the student.
*   `p_class_ids` (integer array): An array of class IDs the student is enrolled in.
*   `p_school_id` (integer): The ID of the school.
*   `p_date` (date): The date for which to check for active forms.

**Returns:**
A `SETOF custom_forms`, which is a table of `custom_forms` records that match the filtering criteria.

## 3. Client-Side Refactoring Plan

The `getActiveFormsForStudent` method in `lib/services/custom_form_service.dart` will be refactored to call the new RPC function.

**File to be updated:** [`lib/services/custom_form_service.dart`](lib/services/custom_form_service.dart)

### Original Method
```dart
  Future<List<CustomForm>> getActiveFormsForStudent(int studentId, List<int> classIds, int schoolId, DateTime date) async { // studentId and classIds changed to int
    // This is complex due to multiple assignment types (whole school, class, student)
    // and date ranges/recurrence.
    // This might be best implemented as a Supabase RPC function (database function).
    // Client-side logic would be very convoluted.
    
    // Placeholder for client-side attempt (less efficient and complex):
    try {
      final String today = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabaseClient
          .from('custom_forms')
          .select()
          .eq('school_id', schoolId) // Assuming CustomForm has school_id
          .lte('active_from', today)
          .gte('active_to', today)
          // .eq('is_daily', true) // Or handle recurrence differently
          // This doesn't filter by assignment yet.
          .order('title', ascending: true);

      List<CustomForm> allActiveForms = response.map((data) => CustomForm.fromMap(data)).toList();
      List<CustomForm> relevantForms = [];

      for (var form in allActiveForms) {
        if (form.assignToWholeSchool) {
          relevantForms.add(form);
          continue;
        }
        // form.assignedStudentIds is List<int>, studentId is int
        if (form.assignedStudentIds.contains(studentId)) {
          relevantForms.add(form);
          continue;
        }
        // classIds is List<int>, form.assignedClassIds is List<int>
        if (classIds.any((classId) => form.assignedClassIds.contains(classId))) {
          relevantForms.add(form);
          continue;
        }
      }
      return relevantForms.toSet().toList(); // Ensure uniqueness
    } catch (e) {
      print('Error fetching active forms for student: $e');
      return [];
    }
  }
```

### Refactored Method
```dart
  Future<List<CustomForm>> getActiveFormsForStudent(int studentId, List<int> classIds, int schoolId, DateTime date) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_active_forms_for_student',
        params: {
          'p_student_id': studentId,
          'p_class_ids': classIds,
          'p_school_id': schoolId,
          'p_date': DateFormat('yyyy-MM-dd').format(date),
        },
      );
      // The RPC function will return a list of form objects (json)
      return (response as List<dynamic>)
          .map((data) => CustomForm.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error calling get_active_forms_for_student RPC: $e');
      return [];
    }
  }
```

This change simplifies the client-side code significantly and delegates the complex filtering logic to the database, where it can be executed much more efficiently.