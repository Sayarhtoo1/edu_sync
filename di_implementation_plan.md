# Dependency Injection (DI) Implementation Plan

## 1. Introduction

This document outlines the strategy for implementing a consistent Dependency Injection (DI) pattern across the application. The goal is to improve code maintainability, testability, and scalability by decoupling components from their concrete dependencies.

## 2. DI Package Selection

### Analysis

The `pubspec.yaml` file lists both `provider` and `get_it` as dependencies. A codebase analysis reveals that `provider` is already extensively used for state management, particularly with `SchoolProvider`, `NotificationService`, and `LocaleProvider`.

### Recommendation

**Use `provider` for Dependency Injection.**

### Justification

*   **Consistency:** The project already relies heavily on `provider` for state management. Using it for DI as well will maintain a single, consistent pattern for accessing services and state, reducing the learning curve for new developers and simplifying the overall architecture.
*   **Simplicity:** Leveraging the existing `provider` setup avoids introducing a second DI/service locator package (`get_it`), which would add unnecessary complexity.
*   **Widget Tree Integration:** `provider` is designed to work seamlessly with Flutter's widget tree, making it a natural choice for providing dependencies to UI components.

## 3. Implementation Plan

The implementation will involve registering services at the top of the widget tree and accessing them where needed. This eliminates direct service instantiation within widgets and other services.

### 3.1. Service Registration

All application services will be registered in the `main.dart` file using `MultiProvider`. This ensures that services are available to the entire application from startup.

**Example `main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/services/student_service.dart';
// ... other service imports

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Register Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<SchoolService>(create: (_) => SchoolService()),
        Provider<StudentService>(create: (_) => StudentService()),
        // ... register other services like ClassService, TimetableService, etc.

        // Existing State Notifiers (ChangeNotifierProvider)
        ChangeNotifierProvider(create: (context) => SchoolProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3.2. Service Access

Dependencies will be accessed from the widget tree using `Provider.of<T>(context)`.

*   For access within `build` methods where the widget should rebuild on changes (less common for services):
    ```dart
    final authService = Provider.of<AuthService>(context);
    ```
*   For access outside of `build` methods (e.g., in `initState`, event handlers) or when the widget should not rebuild on changes:
    ```dart
    final authService = Provider.of<AuthService>(context, listen: false);
    ```

### 3.3. Refactoring Guide

The following files and classes require refactoring to remove direct service instantiations (e.g., `final _authService = AuthService();`) and use the provider-based approach.

#### Services to be Provided:

*   `AuthService`
*   `SchoolService`
*   `StudentService`
*   `ClassService`
*   `TimetableService`
*   `AttendanceService`
*   `LessonPlanService`
*   `CustomFormService`
*   `FormResponseService`
*   `AnnouncementService`
*   `NotificationService`
*   `FinanceService` (if applicable)

#### Key Files/Classes to Refactor:

The primary task is to go through the files identified during the analysis and replace manual instantiations.

**Example Refactoring:**

**Before:**
```dart
// In a widget's state class
class _MyScreenState extends State<MyScreen> {
  final AuthService _authService = AuthService();

  void _someAction() {
    _authService.doSomething();
  }
  // ...
}
```

**After:**
```dart
// In a widget's state class
class _MyScreenState extends State<MyScreen> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  void _someAction() {
    _authService.doSomething();
  }
  // ...
}
```

**List of files identified for refactoring (based on initial search):**

*   `lib/widgets/app_drawer.dart`
*   `lib/screens/teacher/teacher_timetable_screen.dart`
*   `lib/screens/teacher/lesson_plan_management_screen.dart`
*   `lib/screens/teacher/attendance_marking_screen.dart`
*   `lib/screens/teacher/add_edit_lesson_plan_screen.dart`
*   `lib/screens/splash_screen.dart`
*   `lib/screens/role_selection_screen.dart`
*   `lib/screens/parent/daily_report_screen.dart`
*   `lib/screens/parent/child_schedule_screen.dart`
*   `lib/screens/parent/child_attendance_screen.dart`
*   `lib/screens/parent/announcements_screen.dart`
*   `lib/screens/auth/register_screen.dart`
*   `lib/screens/auth/login_screen.dart`
*   `lib/screens/admin/add_edit_student_screen.dart`
*   `lib/screens/admin/admin_panel_screen.dart`
*   `lib/screens/admin/manage_custom_forms_screen.dart`
*   `lib/screens/admin/student_management_screen.dart`
*   `lib/screens/admin/view_form_responses_screen.dart`
*   `lib/screens/admin/user_management_screen.dart`
*   `lib/screens/admin/timetable_management_screen.dart`
*   `lib/screens/admin/staff_management_screen.dart`
*   `lib/screens/admin/finance_management_screen.dart`
*   `lib/screens/admin/class_management_screen.dart`
*   `lib/screens/admin/admin_announcements_screen.dart`
*   `lib/screens/admin/add_edit_timetable_entry_screen.dart`
*   `lib/screens/admin/add_edit_teacher_screen.dart`
*   `lib/screens/admin/add_edit_parent_screen.dart`
*   `lib/screens/admin/add_edit_manager_screen.dart`
*   `lib/screens/admin/add_edit_income_expense_screen.dart`
*   `lib/screens/admin/add_edit_class_screen.dart`
*   `lib/screens/admin/edit_school_profile_screen.dart`
*   `lib/screens/admin/admin_settings_screen.dart`
*   `lib/providers/school_provider.dart`

## 4. Next Steps

1.  **Review:** This plan should be reviewed by the development team.
2.  **Implementation:** Create a task to implement the changes outlined in this document. This can be done incrementally, file by file, to minimize disruption.
3.  **Testing:** Thoroughly test the application after refactoring to ensure all services are correctly provided and consumed.