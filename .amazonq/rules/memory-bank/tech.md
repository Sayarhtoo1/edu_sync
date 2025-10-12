# Technology Stack

## Programming Languages
- **Dart**: ^3.7.2 (primary language for Flutter application)
- **SQL**: Database migrations and schema definitions
- **TypeScript**: Deno-based Gemini API proxy
- **Kotlin**: Android native code (build.gradle.kts)
- **Swift**: iOS/macOS native code
- **C++**: Windows/Linux native code

## Framework and Runtime
- **Flutter SDK**: Cross-platform UI framework
- **Deno**: TypeScript runtime for proxy service

## Backend and Database
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database
  - Authentication and authorization
  - Real-time subscriptions
  - Row Level Security (RLS)
  - Storage for file uploads
  - Edge Functions support

- **Drift**: Local SQLite database (v2.28.1)
  - Type-safe SQL queries
  - Reactive streams
  - Migration support
  - Code generation

## State Management
- **Provider**: ^6.1.5 (primary state management)
- **Flutter Riverpod**: ^2.5.1 (selective usage)
- **ChangeNotifier**: Built-in Flutter state management

## Navigation
- **go_router**: ^16.2.1
  - Declarative routing
  - Deep linking support
  - Route guards and redirects
  - Named routes

## Core Dependencies

### Authentication & Security
- `supabase_flutter`: ^2.10.0 - Backend integration
- `app_links`: ^6.4.1 - Deep linking for password reset

### UI & Visualization
- `syncfusion_flutter_charts`: ^31.1.19 - Analytics charts
- `cached_network_image`: ^3.4.1 - Image caching
- `flutter_svg`: ^2.2.0 - SVG rendering
- `table_calendar`: ^3.1.2 - Calendar views
- `hijri_calendar`: ^1.0.7+7 - Islamic calendar

### Localization
- `intl`: ^0.20.2 - Internationalization
- `flutter_localizations`: SDK - Flutter localization support

### File & Media
- `image_picker`: ^1.1.2 - Camera and gallery access
- `file_picker`: ^8.1.6 - Document selection
- `pdf`: ^3.11.1 - PDF generation
- `printing`: ^5.13.4 - PDF printing and sharing
- `share_plus`: ^10.1.3 - Native sharing

### Data & Storage
- `shared_preferences`: ^2.2.0 - Key-value storage
- `path_provider`: ^2.1.3 - File system paths
- `sqlite3_flutter_libs`: ^0.5.0 - SQLite native libraries

### Networking
- `dio`: ^5.4.3+1 - HTTP client
- `connectivity_plus`: ^6.0.0 - Network status monitoring

### Utilities
- `uuid`: ^4.4.0 - UUID generation
- `collection`: ^1.18.0 - Collection utilities
- `logger`: ^2.3.0 - Logging framework
- `csv`: ^5.0.1 - CSV parsing and generation
- `open_file`: ^3.5.10 - File opening
- `url_launcher`: ^6.3.2 - URL launching
- `package_info_plus`: ^8.3.1 - App version info

### Permissions & Location
- `permission_handler`: ^12.0.1 - Runtime permissions
- `google_maps_flutter`: ^2.6.1 - Maps integration
- `geolocator`: ^12.0.0 - GPS location

### Notifications
- `flutter_local_notifications`: ^19.1.0 - Local notifications

### Dependency Injection
- `get_it`: ^8.0.3 - Service locator

### Environment
- `flutter_dotenv`: ^5.2.1 - Environment variable management

## Development Dependencies

### Testing
- `flutter_test`: SDK - Flutter testing framework
- `mockito`: ^5.4.4 - Mocking library

### Code Generation
- `build_runner`: ^2.8.0 - Code generation runner
- `drift_dev`: ^2.28.1 - Drift code generator

### Code Quality
- `flutter_lints`: ^6.0.0 - Linting rules

### Build Tools
- `flutter_launcher_icons`: ^0.14.4 - App icon generation

## Build System

### Android
- **Gradle**: 8.10.2
- **Kotlin DSL**: build.gradle.kts
- **Min SDK**: 21
- **Target SDK**: Latest

### iOS/macOS
- **Xcode**: Project-based build
- **CocoaPods**: Dependency management
- **Swift**: Native code

### Windows/Linux
- **CMake**: Build system
- **C++**: Native code

### Web
- **Flutter Web**: Compiled to JavaScript

## Development Commands

### Setup
```bash
flutter pub get                    # Install dependencies
flutter pub run build_runner build # Generate code
```

### Development
```bash
flutter run                        # Run in debug mode
flutter run --release              # Run in release mode
flutter run -d windows             # Run on Windows
flutter run -d chrome              # Run on Web
```

### Building
```bash
flutter build apk --release        # Build Android APK
flutter build appbundle            # Build Android App Bundle
flutter build ios                  # Build iOS app
flutter build windows              # Build Windows app
flutter build web                  # Build web app
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch # Watch mode
```

### Localization
```bash
flutter gen-l10n                   # Generate localization files
```

### Testing
```bash
flutter test                       # Run all tests
flutter test test/services/        # Run specific test directory
```

### Database Migrations
```bash
# Supabase migrations
supabase migration new <name>      # Create new migration
supabase db push                   # Apply migrations
supabase db reset                  # Reset database
```

### Icons
```bash
flutter pub run flutter_launcher_icons:main
```

## Environment Configuration

### Required Environment Variables (.env)
- Supabase URL: `https://rcrhktgfkgkwuosyclbo.supabase.co`
- Supabase Anon Key: (stored in .env)

### Configuration Files
- `pubspec.yaml`: Dart dependencies and assets
- `l10n.yaml`: Localization configuration
- `analysis_options.yaml`: Linting rules
- `supabase/config.toml`: Supabase project config

## Version Information
- **App Version**: 3.2.0+1
- **Dart SDK**: ^3.7.2
- **Flutter**: Latest stable

## Platform Support
- ✅ Android (API 21+)
- ✅ iOS
- ✅ Windows
- ✅ Linux
- ✅ macOS
- ✅ Web

## IDE Support
- Android Studio
- Visual Studio Code
- IntelliJ IDEA
- Xcode (for iOS/macOS)

## External Services
- **Supabase**: Backend and database
- **Deno Deploy**: Gemini API proxy hosting
- **Google Maps API**: Location services (requires API key)
