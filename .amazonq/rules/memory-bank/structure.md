# Project Structure

## Directory Organization

### `/lib` - Main Application Code
Core Flutter application with feature-based organization:

- **`/config`**: Application configuration
  - `providers.dart`: Dependency injection setup
  - `router.dart`: GoRouter navigation configuration with role-based routing

- **`/database`**: Local persistence layer
  - `app_database.dart`: Drift database schema definitions
  - `app_database.g.dart`: Generated Drift code
  - `migration_service.dart`: Database migration management

- **`/l10n`**: Internationalization
  - `/gen`: Generated localization files
  - `app_en.arb`: English translations
  - `app_my.arb`: Myanmar language translations

- **`/models`**: Data models (30+ models)
  - Core entities: `user.dart`, `school.dart`, `student.dart`, `teacher.dart`, `staff.dart`, `parent.dart`
  - Academic: `exam.dart`, `exam_subject.dart`, `grade.dart`, `subject.dart`, `student_exam_mark.dart`
  - Operations: `attendance.dart`, `timetable.dart`, `lesson_plan.dart`, `announcement.dart`
  - Finance: `fee_structure.dart`, `fee_payment.dart`, `donation.dart`, `salary_payment.dart`, `income.dart`, `expense.dart`
  - Forms: `custom_form.dart`, `form_field_item.dart`, `form_response.dart`
  - Enums: `user_role.dart`, `exam_status.dart`, `timetable_status.dart`

- **`/providers`**: State management (Provider pattern)
  - `locale_provider.dart`: Language switching
  - `school_provider.dart`: School context management
  - `class_provider.dart`: Class data management
  - `exam_provider.dart`: Exam state management
  - `analytics_provider.dart`: Analytics data aggregation
  - `admin_panel_provider.dart`: Admin dashboard state
  - `staff_attendance_provider.dart`: Staff attendance tracking

- **`/screens`**: UI screens organized by role
  - `/admin`: 20+ admin screens (dashboards, management, finance, exams)
  - `/teacher`: Teacher-specific screens (dashboard, attendance, lesson plans, marks entry)
  - `/parent`: Parent portal screens (child monitoring, schedules, reports)
  - `/student`: Student screens (profile, performance, report cards)
  - `/staff`: Staff member screens (profile, attendance)
  - `/manager`: Manager dashboard and analytics
  - `/donator`: Donator dashboard and donation tracking
  - `/auth`: Authentication screens (login, reset password)
  - `/common`: Shared screens (analytics, report cards)
  - `/settings`: Application settings screens
  - `splash_screen.dart`: Initial loading screen

- **`/services`**: Business logic layer (40+ services)
  - **Auth & Users**: `auth_service.dart`, `user_service.dart`, `role_service.dart`
  - **Academic**: `exam_service.dart`, `exam_crud_service.dart`, `exam_marks_service.dart`, `exam_analytics_service.dart`, `grade_crud_service.dart`, `subject_crud_service.dart`
  - **Operations**: `attendance_service.dart`, `timetable_service.dart`, `lesson_plan_service.dart`, `announcement_service.dart`
  - **Finance**: `finance_service.dart`, `fee_payment_service.dart`, `fee_structure_service.dart`, `donation_service.dart`, `salary_service.dart`
  - **School Management**: `school_service.dart`, `class_service.dart`, `student_service.dart`, `staff_service.dart`
  - **Forms**: `custom_form_service.dart`, `form_response_service.dart`
  - **Utilities**: `notification_service.dart`, `pdf_service.dart`, `cache_service.dart`, `validation_service.dart`, `error_handling_service.dart`, `api_service.dart`

- **`/widgets`**: Reusable UI components
  - `/admin`: Admin-specific widgets
  - `/teacher`: Teacher-specific widgets
  - `/parent`: Parent-specific widgets
  - `/donator`: Donator-specific widgets
  - `/common`: Shared widgets across roles
  - `/app_drawer_components`: Navigation drawer components
  - Common widgets: `app_drawer.dart`, `dashboard_screen.dart`, `language_toggle.dart`, `hijri_calendar_card.dart`

- **`/theme`**: UI theming
  - `app_theme.dart`: Material Design 3 theme configuration

- **`/utils`**: Utility functions
  - `logger.dart`: Logging infrastructure
  - `timetable_status_helper.dart`: Timetable status utilities

### `/supabase` - Backend Configuration
- **`/migrations`**: Database migration SQL files (12+ migrations)
  - Schema definitions for all tables
  - RLS policies and security rules
  - Database functions and triggers
- `config.toml`: Supabase project configuration
- `schema.sql`: Complete database schema
- `seed.sql`: Initial data seeding

### `/docs` - Documentation
- Implementation plans and design documents
- Phase completion reports (Phase 2 & 3)
- Feature-specific documentation (exam module, finance, attendance)
- Task completion reports

### `/plan` - Planning Documents
- Architecture and design plans
- Feature enhancement roadmaps
- Analytics dashboard specifications
- State management optimization plans

### `/test` - Testing
- Unit tests for services (auth, role, attendance, exam)
- Screen tests for admin features
- Mock utilities for testing

### `/android`, `/ios`, `/windows`, `/linux`, `/macos`, `/web` - Platform-Specific Code
- Native platform configurations
- Platform-specific build files
- Generated plugin registrants

### `/deno-gemini-proxy` - External Service
- Deno-based proxy for Gemini API integration
- Deployment configuration for Deno Deploy

### `/assets` - Static Assets
- `/icon`: Application icons (EduSync.png, EduSync.svg)
- Application branding assets

## Core Components and Relationships

### Authentication Flow
1. `SplashScreen` → checks auth state
2. `AuthService` → validates user with Supabase
3. `router.dart` → redirects based on `UserRole`
4. Role-specific dashboard loads

### Data Flow Architecture
```
UI (Screens/Widgets)
    ↓
Providers (State Management)
    ↓
Services (Business Logic)
    ↓
Models (Data Structures)
    ↓
Data Sources (Supabase + Drift)
```

### Key Architectural Patterns

**Provider Pattern**: State management using `provider` package
- Providers wrap services and expose state to UI
- ChangeNotifier for reactive updates
- Context-based dependency injection

**Service Layer**: Business logic separation
- Services handle all data operations
- Services communicate with Supabase and Drift
- Error handling and validation in service layer

**Repository Pattern**: Data access abstraction
- Drift for local caching
- Supabase for remote persistence
- Automatic sync between local and remote

**Role-Based Access Control**:
- `UserRole` enum defines all roles
- `RoleService` manages role assignments
- Router guards routes based on roles
- UI components conditionally render based on roles

### Navigation Architecture
- **GoRouter**: Declarative routing with deep linking support
- **Role-based redirects**: Automatic navigation to appropriate dashboard
- **Deep linking**: Password reset and app links support
- **Route guards**: Authentication and connectivity checks

### Offline-First Strategy
- Drift database caches all critical data
- `CacheService` manages sync state
- Connectivity checks before network operations
- Graceful degradation when offline

## Module Dependencies

### Core Dependencies
- `flutter`: UI framework
- `supabase_flutter`: Backend and authentication
- `provider`: State management
- `go_router`: Navigation
- `drift`: Local database

### Feature Dependencies
- `syncfusion_flutter_charts`: Analytics visualizations
- `pdf` + `printing`: Report card generation
- `table_calendar`: Exam calendar views
- `hijri_calendar`: Islamic calendar support
- `image_picker`: Profile photo uploads
- `file_picker`: Document uploads
- `csv`: Data export functionality

### Platform Dependencies
- `google_maps_flutter`: Location features
- `geolocator`: GPS tracking
- `permission_handler`: Runtime permissions
- `connectivity_plus`: Network status monitoring
- `app_links`: Deep linking support
