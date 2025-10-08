# Analytics Data Requirements

This document outlines the data requirements for the Analytics Dashboard.

## 1. New Supabase RPC Functions

The following RPC functions will be created in Supabase to aggregate analytics data:

*   **`get_school_performance_overview(school_id INT)`:**
    *   **Description:** Returns an overview of the school's performance, including total students, average marks, and overall pass/fail rate.
    *   **Returns:** A JSON object with the aggregated data.

*   **`get_class_performance_overview(class_id INT)`:**
    *   **Description:** Returns an overview of a class's performance, including total students, average marks, and pass/fail rate.
    *   **Returns:** A JSON object with the aggregated data.

*   **`get_subject_performance(school_id INT, class_id INT)`:**
    *   **Description:** Returns the performance for each subject in a given school or class, including average marks, pass/fail rates, and grade distribution.
    *   **Returns:** A list of JSON objects, where each object represents a subject.

*   **`get_student_progress(student_id INT)`:**
    *   **Description:** Returns the performance of a student over time, showing their marks in different exams for each subject.
    *   **Returns:** A list of JSON objects, where each object represents an exam result for a subject.

## 2. `ExamService` Modifications

The following methods will be added to `ExamService` to call the new RPC functions:

```dart
Future<Map<String, dynamic>> getSchoolPerformanceOverview(int schoolId);
Future<Map<String, dynamic>> getClassPerformanceOverview(int classId);
Future<List<dynamic>> getSubjectPerformance({int? schoolId, int? classId});
Future<List<dynamic>> getStudentProgress(int studentId);
```

## 3. `AnalyticsProvider`

A new provider, `AnalyticsProvider`, will be created to manage the state of the analytics dashboard. It will use `ExamService` to fetch the data and make it available to the UI.

The provider will have the following properties:

*   `schoolPerformanceOverview`: Stores the overview of the school's performance.
*   `classPerformanceOverview`: Stores the overview of a class's performance.
*   `subjectPerformance`: Stores the performance data for subjects.
*   `studentProgress`: Stores the progress data for a student.
*   `isLoading`: A boolean to indicate if data is being fetched.

And the following methods:

*   `fetchSchoolPerformanceOverview(int schoolId)`
*   `fetchClassPerformanceOverview(int classId)`
*   `fetchSubjectPerformance({int? schoolId, int? classId})`
*   `fetchStudentProgress(int studentId)`
