# Technology Stack

## Programming Languages
- **Dart**: ^3.7.2 (Primary language for Flutter application)
- **TypeScript**: Deno proxy service implementation
- **C++**: Windows and Linux native platform code
- **Swift**: iOS and macOS native platform code
- **Kotlin**: Android native platform code
- **SQL**: Database migrations and schema

## Framework & Runtime
- **Flutter SDK**: Cross-platform UI framework
- **Deno**: TypeScript/JavaScript runtime for proxy service

## Core Dependencies

### State Management
- `provider: ^6.1.5` - Primary state management solution
- `flutter_riverpod: ^2.5.1` - Alternative state management for specific features
- `get_it: ^8.0.3` - Service locator for dependency injection

### Backend & Database
- `supabase_flutter: ^2.10.0` - Supabase client for authentication, database, and real-time features
- `drift: ^2.28.1` - Type-safe SQL database for local storage
- `sqlite3_flutter_libs: ^0.5.0` - SQLite native libraries
- `path_provider: ^2.1.3` - File system path access
- `path: ^1.9.0` - Path manipulation utilities

### Navigation & Routing
- `go_router: ^16.2.1` - Declarative routing with deep linking
- `app_links: ^6.4.1` - Deep link handling

### UI & Visualization
- `syncfusion_flutter_charts: ^31.1.19` - Advanced charting and data visualization
- `fl_chart: ^0.66.0` - Additional charting library
- `table_calendar: ^3.1.2` - Calendar widget for scheduling
- `cached_network_image: ^3.4.1` - Image caching and loading
- `flutter_svg: ^2.2.0` - SVG rendering support

### Localization
- `intl: ^0.20.2` - Internationalization and formatting
- `flutter_localizations` (SDK) - Flutter localization support
- `hijri_calendar: ^1.0.7+7` - Islamic calendar support

### Notifications & Communication
- `flutter_local_notifications: ^19.1.0` - Local push notifications
- `connectivity_plus: ^6.0.0` - Network connectivity monitoring

### File & Media Handling
- `image_picker: ^1.1.2` - Image selection from camera/gallery
- `file_picker: ^8.1.6` - File selection
- `pdf: ^3.11.1` - PDF generation
- `printing: ^5.13.4` - PDF printing and sharing
- `share_plus: ^10.1.3` - Native sharing functionality
- `open_file: ^3.5.10` - File opening with default apps
- `csv: ^5.0.1` - CSV file parsing and generation

### Networking & API
- `dio: ^5.4.3+1` - HTTP client for API requests
- `url_launcher: ^6.3.2` - URL and external app launching

### Location & Maps
- `google_maps_flutter: ^2.6.1` - Google Maps integration
- `geolocator: ^12.0.0` - Location services

### Storage & Preferences
- `shared_preferences: ^2.2.0` - Key-value storage
- `flutter_dotenv: ^5.2.1` - Environment variable management

### Utilities
- `uuid: ^4.4.0` - UUID generation
- `collection: ^1.18.0` - Collection utilities
- `logger: ^2.3.0` - Logging framework
- `package_info_plus: ^8.3.1` - App package information
- `permission_handler: ^12.0.1` - Runtime permissions

### UI Components
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Development Dependencies

### Testing
- `flutter_test` (SDK) - Flutter testing framework
- `mockito: ^5.4.4` - Mocking framework for unit tests

### Code Quality
- `flutter_lints: ^6.0.0` - Recommended linting rules

### Build Tools
- `build_runner: ^2.8.0` - Code generation runner
- `drift_dev: ^2.28.1` - Drift code generation
- `flutter_launcher_icons: ^0.14.4` - App icon generation

## Build System
- **Gradle**: Android build system (Kotlin DSL)
- **Xcode**: iOS/macOS build system
- **CMake**: Windows/Linux build system

## Development Commands

### Running the Application
```bash
flutter run                    # Run on connected device
flutter run -d windows         # Run on Windows
flutter run -d chrome          # Run on web
flutter run --release          # Release build
```

### Building
```bash
flutter build apk              # Android APK
flutter build appbundle        # Android App Bundle
flutter build ios              # iOS build
flutter build windows          # Windows executable
flutter build web              # Web build
```

### Code Generation
```bash
flutter pub run build_runner build              # Generate code
flutter pub run build_runner build --delete-conflicting-outputs  # Force regenerate
```

### Localization
```bash
flutter gen-l10n               # Generate localization files
```

### Testing
```bash
flutter test                   # Run all tests
flutter test test/services/    # Run specific test directory
```

### Maintenance
```bash
flutter pub get                # Install dependencies
flutter pub upgrade            # Upgrade dependencies
flutter clean                  # Clean build artifacts
flutter doctor                 # Check Flutter installation
```

## Environment Configuration
- `.env` file for environment variables (Supabase URL, API keys)
- `devtools_options.yaml` for Flutter DevTools configuration
- `analysis_options.yaml` for static analysis rules
- `l10n.yaml` for localization configuration

## Version
- **Current Version**: 3.3.1
- **Minimum Android SDK**: 21
- **SDK Constraints**: ^3.7.2

## Backend Services
- **Supabase**: 
  - URL: https://rcrhktgfkgkwuosyclbo.supabase.co
  - Authentication, PostgreSQL database, real-time subscriptions, storage
- **Deno Deploy**: Gemini API proxy service

## Platform Support
- Android (API 21+)
- iOS
- Windows
- Linux
- macOS
- Web
