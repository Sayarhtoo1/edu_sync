# Project Structure

## Directory Organization

### `/lib` - Main Application Code
Core Flutter application source code organized by functionality.

#### `/lib/config`
- `providers.dart` - Dependency injection and provider initialization
- `router.dart` - GoRouter configuration with role-based navigation and deep linking

#### `/lib/models`
Data models representing business entities:
- User management: `user.dart`, `user_role.dart`, `parent.dart`, `teacher.dart`, `staff.dart`, `student.dart`
- Academic: `school.dart`, `school_class.dart`, `subject.dart`, `grade.dart`, `lesson_plan.dart`
- Exam system: `exam.dart`, `exam_class.dart`, `exam_subject.dart`, `exam_template.dart`, `exam_status.dart`, `student_exam_mark.dart`, `marks_approval.dart`
- Attendance: `attendance.dart`, `attendance_report.dart`
- Finance: `fee_structure.dart`, `fee_payment.dart`, `income.dart`, `expense.dart`, `donation.dart`, `salary_payment.dart`, `finance_category.dart`, `financial_report.dart`
- Scheduling: `timetable.dart`, `timetable_status.dart`, `schedule_summary.dart`
- Communication: `announcement.dart`, `custom_form.dart`, `form_field_item.dart`, `form_field_type.dart`, `form_response.dart`, `form_response_answer.dart`

#### `/lib/services`
Business logic and API integration (45+ services):
- Authentication: `auth_service.dart`, `role_service.dart`
- Core services: `api_service.dart`, `cache_service.dart`, `error_handling_service.dart`, `notification_service.dart`
- Academic services: `student_service.dart`, `staff_service.dart`, `class_service.dart`, `subject_crud_service.dart`, `grade_crud_service.dart`
- Exam services: `exam_service.dart`, `exam_crud_service.dart`, `exam_marks_service.dart`, `exam_analytics_service.dart`, `exam_analytics_enhanced_service.dart`, `exam_report_service.dart`, `exam_scheduler_service.dart`, `exam_template_service.dart`, `exam_notification_service.dart`, `exam_csv_service.dart`, `marks_approval_service.dart`, `student_exam_mark_service.dart`
- Finance services: `finance_service.dart`, `fee_structure_service.dart`, `fee_payment_service.dart`, `donation_service.dart`, `salary_service.dart`, `finance_category_service.dart`, `financial_report_service.dart`
- Attendance: `attendance_service.dart`
- Scheduling: `timetable_service.dart`, `lesson_plan_service.dart`, `schedule_summary_service.dart`
- Communication: `announcement_service.dart`, `custom_form_service.dart`, `form_response_service.dart`
- Utilities: `pdf_service.dart`, `validation_service.dart`, `update_service.dart`, `performance_monitor_service.dart`

#### `/lib/providers`
State management providers using Provider pattern:
- `locale_provider.dart` - Language/localization state
- `school_provider.dart` - Current school context
- `class_provider.dart` - Class selection and management
- `exam_provider.dart` - Exam state management
- `admin_panel_provider.dart` - Admin UI state
- `analytics_provider.dart` - Analytics data state
- `school_settings_provider.dart` - School configuration
- `staff_attendance_provider.dart` - Staff attendance state

#### `/lib/screens`
UI screens organized by user role:
- `/admin` - Administrative screens (40+ screens including exam, finance, staff, student management)
- `/teacher` - Teacher-specific screens (dashboard, attendance, marks entry, lesson plans)
- `/parent` - Parent portal screens (child info, attendance, schedule, announcements)
- `/student` - Student screens (profile, performance, report cards)
- `/staff` - Staff screens (profile)
- `/manager` - Manager dashboard
- `/donator` - Donor dashboard
- `/auth` - Authentication screens (login, reset password)
- `/settings` - Application settings
- `/common` - Shared screens (analytics, report cards)
- `/desktop` - Desktop-optimized versions of all screens

#### `/lib/widgets`
Reusable UI components:
- `/admin` - Admin-specific widgets
- `/teacher` - Teacher-specific widgets
- `/parent` - Parent-specific widgets
- `/donator` - Donator-specific widgets
- `/common` - Shared widgets
- `/app_drawer_components` - Navigation drawer components
- Root-level widgets: `app_drawer.dart`, `dashboard_screen.dart`, `announcement_popup_dialog.dart`, `in_app_notification_popup.dart`, etc.

#### `/lib/theme`
- `app_theme.dart` - Application-wide theme configuration

#### `/lib/utils`
Utility functions and helpers:
- `logger.dart` - Logging utilities
- `responsive.dart` - Responsive design helpers
- `pdf_generator.dart` - PDF generation utilities
- `timetable_status_helper.dart` - Timetable status management

#### `/lib/l10n`
Internationalization and localization:
- `/gen` - Generated localization files
- `app_en.arb` - English translations
- `app_my.arb` - Myanmar (Burmese) translations

#### `/lib/database`
Local database using Drift:
- `app_database.dart` - Database schema and DAOs
- `app_database.g.dart` - Generated database code
- `migration_service.dart` - Database migration management

### `/supabase` - Backend Configuration
- `/migrations` - Database migration SQL files (14+ migrations)
- `schema.sql` - Complete database schema
- `seed.sql` - Initial data seeding
- `config.toml` - Supabase configuration

### `/deno-gemini-proxy` - Proxy Service
- Deno-based proxy service for Gemini API integration
- `main.ts` - Proxy server implementation

### Platform-Specific Directories
- `/android` - Android platform configuration and build files
- `/ios` - iOS platform configuration
- `/windows` - Windows platform configuration
- `/linux` - Linux platform configuration
- `/macos` - macOS platform configuration
- `/web` - Web platform assets and configuration

### `/docs` - Documentation
Comprehensive project documentation including:
- Implementation plans and completion reports
- Feature enhancement documentation
- Phase completion reports (Phases 1-5)
- Module-specific documentation (exam, finance, attendance)

### `/plan` - Planning Documents
Architecture and design documents:
- Analytics dashboard architecture
- Exam module planning
- Feature enhancement plans
- RPC design and optimization plans
- State management optimization

### `/test` - Test Suite
- Unit tests for services (auth, attendance, exam, role)
- Screen tests
- Test utilities and mocks

### `/assets` - Static Assets
- Application icons and images
- SVG assets

## Core Architectural Patterns

### State Management
- **Provider Pattern**: Primary state management using `provider` package
- **Riverpod**: Used alongside Provider for specific features
- Centralized provider initialization in `config/providers.dart`

### Navigation
- **GoRouter**: Declarative routing with deep linking support
- Role-based route guards and redirects
- Platform-adaptive screen routing (mobile/desktop)

### Backend Integration
- **Supabase**: Backend-as-a-Service for authentication, database, and real-time features
- RESTful API patterns through Supabase client
- Real-time subscriptions for announcements and notifications

### Local Storage
- **Drift**: Type-safe SQL database for offline support
- **SharedPreferences**: Simple key-value storage for settings
- **Cache Service**: Intelligent caching layer for API responses

### Platform Adaptation
- **PlatformAdaptiveScreen**: Widget wrapper for mobile/desktop variants
- Responsive design utilities for different screen sizes
- Platform-specific implementations where needed

### Service Layer Architecture
- Clear separation between UI (screens/widgets) and business logic (services)
- Services handle all API communication and data transformation
- Error handling centralized in `error_handling_service.dart`

### Localization
- Flutter's built-in localization support
- ARB files for translations (English and Myanmar)
- Runtime locale switching via `LocaleProvider`
