# Project Structure

## Directory Organization

### `/lib` - Main Application Code
Core Flutter application source code organized by architectural layers.

#### `/lib/config`
- `providers.dart` - Dependency injection setup with GetIt service locator
- `router.dart` - GoRouter configuration for navigation and routing

#### `/lib/database`
- `app_database.dart` - Drift database schema definitions
- `app_database.g.dart` - Generated Drift database code
- `migration_service.dart` - Local database migration management

#### `/lib/l10n`
- `app_en.arb` - English localization strings
- `app_my.arb` - Myanmar/Burmese localization strings
- `/gen` - Generated localization code

#### `/lib/models`
Data models representing business entities:
- User models: `user.dart`, `parent.dart`, `teacher.dart`, `student.dart`, `staff.dart`
- Academic models: `school_class.dart`, `subject.dart`, `exam.dart`, `grade.dart`, `lesson_plan.dart`
- Scheduling: `timetable.dart`, `schedule_summary.dart`
- Tracking: `attendance.dart`, `attendance_report.dart`
- Finance: `income.dart`, `expense.dart`
- Communication: `announcement.dart`
- Forms: `custom_form.dart`, `form_response.dart`, `form_field_item.dart`
- Enums: `user_role.dart`, `exam_status.dart`, `timetable_status.dart`

#### `/lib/providers`
State management with Riverpod and Provider:
- `admin_panel_provider.dart` - Admin dashboard state
- `analytics_provider.dart` - Analytics data management
- `class_provider.dart` - Class selection and management
- `exam_provider.dart` - Exam state management
- `locale_provider.dart` - Language/locale management
- `school_provider.dart` - School data state
- `school_settings_provider.dart` - School configuration
- `staff_attendance_provider.dart` - Staff attendance state

#### `/lib/screens`
UI screens organized by user role:
- `/admin` - Administrator screens
- `/teacher` - Teacher-specific screens
- `/parent` - Parent portal screens
- `/student` - Student portal screens
- `/staff` - Staff management screens
- `/manager` - Manager role screens
- `/auth` - Authentication screens (login, signup, password reset)
- `/common` - Shared screens across roles
- `/settings` - Application settings screens
- `splash_screen.dart` - App initialization screen
- `role_selection_screen.dart` - Role-based navigation entry

#### `/lib/services`
Business logic and API integration layer:
- Authentication: `auth_service.dart`, `role_service.dart`, `user_service.dart`
- Academic: `class_service.dart`, `exam_service.dart`, `exam_crud_service.dart`, `exam_subject_service.dart`, `grade_crud_service.dart`, `subject_crud_service.dart`, `lesson_plan_service.dart`
- Scheduling: `timetable_service.dart`, `schedule_summary_service.dart`, `exam_scheduler_service.dart`
- Tracking: `attendance_service.dart`, `staff_service.dart`, `student_service.dart`
- Communication: `announcement_service.dart`, `notification_service.dart`
- Finance: `finance_service.dart`
- Forms: `custom_form_service.dart`, `form_response_service.dart`
- Analytics: `exam_analytics_service.dart`
- Infrastructure: `api_service.dart`, `cache_service.dart`, `error_handling_service.dart`, `performance_monitor_service.dart`, `validation_service.dart`, `update_service.dart`
- School: `school_service.dart`

#### `/lib/theme`
- `app_theme.dart` - Application-wide theme configuration

#### `/lib/utils`
- `logger.dart` - Logging utility
- `timetable_status_helper.dart` - Timetable status helpers

#### `/lib/widgets`
Reusable UI components:
- `/app_drawer_components` - Navigation drawer components
- `app_drawer.dart` - Main navigation drawer
- `dashboard_screen.dart` - Dashboard widget
- `admin_action_card.dart` - Admin action cards
- `child_overview_card.dart` - Parent child overview
- `teacher_class_overview_card.dart` - Teacher class summary
- `hijri_calendar_card.dart` - Islamic calendar widget
- `in_app_notification_popup.dart` - Notification popup
- `language_toggle.dart` - Language switcher
- `profile_photo_view.dart` - Profile photo display
- `date_display_widget.dart` - Date formatting widget

#### `/lib/main.dart`
Application entry point with initialization logic.

### `/supabase` - Backend Configuration
- `/migrations` - Database migration SQL files
- `schema.sql` - Complete database schema
- `seed.sql` - Initial data seeding
- `config.toml` - Supabase project configuration

### `/test` - Test Suite
- `/services` - Service layer unit tests
- `/screens/admin` - Admin screen tests
- `auth_service_test.dart` - Authentication tests
- `role_service_test.dart` - Role management tests
- `widget_test.dart` - Widget tests
- Mock files: `*.mocks.dart`

### `/docs` - Documentation
- `attendance_report_plan.md` - Attendance feature design
- `finance_enhancements_design.md` - Finance module design
- `finance_overview_design.md` - Finance overview specs
- `in_app_notification_design.md` - Notification system design

### `/plan` - Planning Documents
- Architecture and design documents
- Feature enhancement plans
- Analytics dashboard specifications
- Optimization plans (N+1 queries, state management)
- RPC design documentation

### `/android`, `/ios`, `/windows`, `/linux`, `/macos`, `/web`
Platform-specific build configurations and native code.

### `/deno-gemini-proxy`
Deno-based proxy service for Gemini API integration.

### `/assets`
Static assets including icons and images.

## Core Components and Relationships

### Authentication Flow
`main.dart` → `AuthService` → Supabase Auth → Role-based routing via `router.dart`

### Data Flow Architecture
1. **UI Layer**: Screens consume data from Providers
2. **State Management**: Providers manage state using Riverpod/Provider
3. **Service Layer**: Services handle business logic and API calls
4. **Data Layer**: Supabase (remote) + Drift (local cache)
5. **Offline Support**: CacheService manages offline data persistence

### Service Dependencies
- Services injected via GetIt in `providers.dart`
- Services depend on SupabaseClient, SharedPreferences, Connectivity
- NotificationService integrates with AuthService for user-specific subscriptions

## Architectural Patterns

### Layered Architecture
- **Presentation Layer**: Screens and Widgets
- **State Management Layer**: Providers
- **Business Logic Layer**: Services
- **Data Access Layer**: Supabase + Drift

### Dependency Injection
- GetIt service locator pattern
- Services registered in `config/providers.dart`
- Constructor injection for testability

### Offline-First Pattern
- Local Drift database for caching
- Connectivity checking before API calls
- Fallback to cached data when offline
- Background sync when connection restored

### Repository Pattern
- Services act as repositories
- Abstract data source (Supabase vs local cache)
- Consistent API for data access

### Role-Based Access Control
- UserRole enum defines roles (Admin, Teacher, Parent, Student)
- Router guards check authentication and role
- Services filter data by school_id and user role
- UI components conditionally render based on role
