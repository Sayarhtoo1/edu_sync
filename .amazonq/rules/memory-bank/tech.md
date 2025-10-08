# Technology Stack

## Programming Languages
- **Dart**: ^3.7.2 (Primary language for Flutter application)
- **SQL**: Database migrations and schema definitions
- **TypeScript**: Deno proxy service (deno-gemini-proxy)
- **Kotlin**: Android native code (build.gradle.kts)
- **Swift**: iOS/macOS native code
- **C++**: Windows/Linux native code

## Framework and Runtime
- **Flutter**: Cross-platform mobile/desktop framework
- **Flutter SDK**: Latest stable version
- **Deno**: TypeScript runtime for proxy service

## Backend and Database
- **Supabase**: Backend-as-a-Service platform
  - PostgreSQL database
  - Authentication service
  - Real-time subscriptions
  - Edge Functions
  - Storage service
- **Drift**: ^2.28.1 - Local SQLite database for offline caching
- **sqlite3_flutter_libs**: ^0.5.0 - SQLite native libraries

## State Management
- **flutter_riverpod**: ^2.5.1 - Primary state management
- **provider**: ^6.1.5 - Additional state management

## Core Dependencies

### Authentication & Security
- **supabase_flutter**: ^2.10.0 - Supabase client SDK

### Navigation
- **go_router**: ^16.2.1 - Declarative routing
- **app_links**: ^6.4.1 - Deep linking support

### Localization
- **intl**: ^0.20.2 - Internationalization
- **flutter_localizations**: SDK - Flutter localization support

### UI Components
- **cupertino_icons**: ^1.0.8 - iOS-style icons
- **syncfusion_flutter_charts**: ^31.1.19 - Data visualization charts
- **flutter_svg**: ^2.2.0 - SVG rendering
- **cached_network_image**: ^3.4.1 - Image caching

### Data & Storage
- **shared_preferences**: ^2.2.0 - Key-value storage
- **path_provider**: ^2.1.3 - File system paths
- **path**: ^1.9.0 - Path manipulation

### Networking
- **connectivity_plus**: ^6.0.0 - Network connectivity detection
- **dio**: ^5.4.3+1 - HTTP client
- **url_launcher**: ^6.3.2 - URL launching

### Notifications
- **flutter_local_notifications**: ^19.1.0 - Local push notifications

### Media & Files
- **image_picker**: ^1.1.2 - Image selection
- **csv**: ^5.0.1 - CSV file handling
- **open_file**: ^3.5.10 - File opening

### Location Services
- **google_maps_flutter**: ^2.6.1 - Google Maps integration
- **geolocator**: ^12.0.0 - Geolocation services
- **permission_handler**: ^12.0.1 - Runtime permissions

### Utilities
- **uuid**: ^4.4.0 - UUID generation
- **collection**: ^1.18.0 - Collection utilities
- **hijri_calendar**: ^1.0.7+7 - Islamic calendar
- **logger**: ^2.3.0 - Logging utility
- **flutter_dotenv**: ^5.2.1 - Environment variables
- **package_info_plus**: ^8.3.1 - App package information

## Development Dependencies
- **flutter_test**: SDK - Testing framework
- **mockito**: ^5.4.4 - Mocking library for tests
- **flutter_lints**: ^6.0.0 - Linting rules
- **build_runner**: ^2.8.0 - Code generation
- **drift_dev**: ^2.28.1 - Drift code generation
- **flutter_launcher_icons**: ^0.14.4 - App icon generation

## Build System
- **Gradle**: 8.10.2 (Android builds)
- **Kotlin DSL**: build.gradle.kts files
- **CMake**: Native builds (Windows, Linux)
- **Xcode**: iOS/macOS builds
- **Flutter Build**: Cross-platform compilation

## Development Commands

### Setup
```bash
# Install dependencies
flutter pub get

# Generate code (Drift, localization)
flutter pub run build_runner build --delete-conflicting-outputs

# Generate app icons
flutter pub run flutter_launcher_icons
```

### Development
```bash
# Run on connected device
flutter run

# Run with specific flavor/environment
flutter run --dart-define-from-file=.env

# Hot reload (during development)
# Press 'r' in terminal or use IDE hot reload
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### Code Generation
```bash
# Generate Drift database code
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Windows
flutter build windows --release

# Build Web
flutter build web --release
```

### Database Migrations
```bash
# Apply Supabase migrations
supabase db push

# Reset database
supabase db reset

# Generate TypeScript types
supabase gen types typescript --local > lib/types/database.types.ts
```

### Localization
```bash
# Generate localization files (automatic with flutter pub get)
flutter gen-l10n
```

## Environment Configuration
- **.env**: Environment variables (Supabase URL, API keys)
- **supabase/config.toml**: Supabase project configuration
- **analysis_options.yaml**: Dart analyzer configuration
- **l10n.yaml**: Localization configuration
- **pubspec.yaml**: Package dependencies and assets

## Platform Support
- ✅ Android (API 21+)
- ✅ iOS
- ✅ Windows
- ✅ Linux
- ✅ macOS
- ✅ Web

## Version Information
- **App Version**: 2.0.0+1
- **Minimum Android SDK**: 21
- **Dart SDK**: ^3.7.2

## IDE Configuration
- **devtools_options.yaml**: Flutter DevTools configuration
- **.metadata**: Flutter project metadata
- **analysis_options.yaml**: Linter and analyzer rules
