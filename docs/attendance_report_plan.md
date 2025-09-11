# Attendance Report Screen Implementation Plan

This document outlines the plan for creating a new attendance report screen for the EduSync application. The plan incorporates requirements for modular code, UI consistency, and role-based data access.

## 1. Backend Logic: `AttendanceService`

A dedicated service will be created at `lib/services/attendance_service.dart` to handle all attendance-related data fetching. This service will contain specific methods to securely query the database for each role:

-   `getAttendanceForAdmin(int schoolId, DateTime startDate, DateTime endDate)`: Fetches attendance records for all students within the school.
-   `getAttendanceForTeacher(String teacherId, DateTime startDate, DateTime endDate)`: Fetches attendance records for all students in the teacher's assigned classes.
-   `getAttendanceForParent(String parentId, DateTime startDate, DateTime endDate)`: Fetches attendance records for the parent's linked children.

These methods will perform the necessary database joins and filtering within the app to ensure data security, as RLS is not enabled.

## 2. Data Structure: `AttendanceReport` Model

A model file will be created at `lib/models/attendance_report.dart` to define a clean structure for the report data. This will include fields such as `studentName`, `date`, `status`, and `className`.

## 3. UI: Reusable `AttendanceReportScreen`

A single, reusable screen will be created at `lib/screens/common/attendance_report_screen.dart`. To keep the code modular and under 200 lines per file, the screen will be broken down into smaller, reusable widgets.

### 3.1. Main Screen (`attendance_report_screen.dart`)

-   **State Management:** The screen will be a `StatefulWidget` to handle the UI state (selected dates, report data, loading status).
-   **UI Composition:** The main screen will be composed of smaller widgets for the date range selection and the report display.

### 3.2. UI Components (`lib/screens/common/attendance_report_components/`)

-   **`date_range_selector.dart`:** A widget for selecting the report type ("Monthly" or "Custom Range") and the date range.
-   **`report_display.dart`:** A widget that takes the report data and displays it in a user-friendly format. It will use a `DataTable` for admins/teachers and a `ListView` for parents.
-   **`export_button.dart`:** A widget for exporting the report to CSV or PDF format.

## 4. Integration: Connecting the Screen

The new screen will be integrated into the existing UI by adding an "Attendance Report" button or link to the main dashboard for each role:

-   `lib/screens/admin/admin_panel_screen.dart`
-   `lib/screens/teacher/teacher_dashboard_screen.dart`
-   `lib/screens/parent/parent_dashboard_screen.dart`

## 5. UI Consistency

The new screen and its components will adhere to the existing UI theme, colors, and styles found in the other screens to ensure a consistent user experience.
