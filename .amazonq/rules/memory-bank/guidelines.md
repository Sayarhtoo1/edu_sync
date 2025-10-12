# Development Guidelines

## Code Quality Standards

### File Organization
- **Consistent imports ordering**: Standard library imports first, then package imports, then local imports
- **Import aliasing**: Use aliases to avoid naming conflicts (e.g., `import 'package:edu_sync/models/user.dart' as app_user;`)
- **Separation of concerns**: Services handle business logic, providers manage state, screens handle UI
- **Single responsibility**: Each file/class has one clear purpose

### Naming Conventions
- **Files**: snake_case (e.g., `auth_service.dart`, `user_management_screen.dart`)
- **Classes**: PascalCase (e.g., `AuthService`, `UserManagementScreen`)
- **Variables/Functions**: camelCase (e.g., `getCurrentUser`, `isLoading`)
- **Constants**: camelCase with const keyword (e.g., `const appBackgroundColor`)
- **Private members**: Prefix with underscore (e.g., `_supabaseClient`, `_isLoading`)
- **Enums**: PascalCase with PascalCase values (e.g., `UserRole.Admin`)

### Code Formatting
- **Line length**: Keep reasonable (no strict limit enforced)
- **Indentation**: 2 spaces (Dart standard)
- **Braces**: Opening brace on same line
- **Trailing commas**: Use for multi-line parameter lists and collections
- **String literals**: Use single quotes for strings, double quotes for interpolation when needed
- **Comments**: Use `//` for single-line, `///` for documentation comments
- **Blank lines**: Separate logical sections within methods

### Documentation Standards
- **Class documentation**: Brief description of purpose and responsibility
- **Method documentation**: Document public methods with purpose, parameters, and return values
- **Inline comments**: Explain complex logic, business rules, and non-obvious decisions
- **TODO comments**: Mark incomplete features or known issues
- **Warning comments**: Use `// IMPORTANT:` or `// CRITICAL:` for critical information

## Architectural Patterns

### Service Layer Pattern
**Frequency: Used in 40+ service files**

Services encapsulate all business logic and data access:

```dart
class AuthService {
  final SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;
  final Connectivity _connectivity;
  final NotificationService _notificationService;

  AuthService({
    required SupabaseClient supabaseClient,
    required SharedPreferences sharedPreferences,
    required Connectivity connectivity,
    required NotificationService notificationService,
  })  : _supabaseClient = supabaseClient,
        _prefs = sharedPreferences,
        _connectivity = connectivity,
        _notificationService = notificationService;

  Future<User?> signIn(String email, String password) async {
    final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }
}
```

**Key principles:**
- Constructor dependency injection with named parameters
- Private fields for dependencies
- Async methods return Future<T>
- Error handling with try-catch and logger
- No direct UI dependencies

### Provider Pattern for State Management
**Frequency: Used in 8+ provider files**

Providers extend ChangeNotifier for reactive state:

```dart
class SchoolProvider with ChangeNotifier {
  School? _currentSchool;
  bool _isLoading = false;
  final SchoolService _schoolService;
  final AuthService _authService;

  SchoolProvider(this._schoolService, this._authService);

  School? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentSchool() async {
    _isLoading = true;
    notifyListeners();
    
    // Business logic here
    
    _isLoading = false;
    notifyListeners();
  }
}
```

**Key principles:**
- Private state variables with public getters
- Call `notifyListeners()` after state changes
- Loading states for async operations
- Inject services via constructor
- Clear separation from UI logic

### Model Pattern
**Frequency: Used in 30+ model files**

Immutable data classes with factory constructors:

```dart
class User {
  final String id;
  final String role;
  final String? profilePhotoUrl;
  final String? fullName;
  final int? schoolId;

  User({
    required this.id,
    required this.role,
    this.profilePhotoUrl,
    this.fullName,
    this.schoolId,
  });

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      role: map['role'] ?? 'user',
      profilePhotoUrl: map['profile_photo_url'],
      fullName: map['full_name'],
      schoolId: map['school_id'],
    );
  }

  User copyWith({
    String? id,
    String? role,
    String? profilePhotoUrl,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
```

**Key principles:**
- Final fields for immutability
- Named constructors for different sources (fromJson, fromMap)
- copyWith method for creating modified copies
- toMap/toJson for serialization
- Null safety with nullable types (?)

### Router Pattern with GoRouter
**Frequency: Single router configuration**

Declarative routing with guards and redirects:

```dart
GoRouter initializeRouter() {
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loggedIn = authService.getCurrentUser() != null;
      
      if (!loggedIn && !goingToLogin) {
        return '/login';
      }
      
      if (loggedIn && state.matchedLocation == '/') {
        final role = await authService.getUserRole();
        if (role == UserRole.Admin.name) {
          return '/admin';
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/admin',
        builder: (context, state) => const ModernAdminDashboard(),
      ),
    ],
  );
}
```

**Key principles:**
- Centralized route configuration
- Role-based redirects
- Authentication guards
- Named routes for type-safe navigation
- Deep linking support

## Common Implementation Patterns

### Error Handling Pattern
**Frequency: Used throughout services**

```dart
Future<List<User>> getUsersByRole(UserRole role, int schoolId) async {
  try {
    final response = await _supabaseClient
        .from('users')
        .select()
        .eq('role', role.name)
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return response.map((userData) => User.fromJson(userData)).toList();
  } catch (e) {
    logger.e('Error fetching users by role: $e');
    return [];
  }
}
```

**Key principles:**
- Try-catch blocks for all async operations
- Log errors with context using logger
- Return safe defaults (empty lists, null) on error
- Don't expose raw exceptions to UI

### Caching Pattern
**Frequency: Used in auth and data services**

```dart
Future<String?> getUserRole() async {
  final currentUser = _supabaseClient.auth.currentUser;
  if (currentUser == null) return null;

  // Try cache first
  String? cachedRole = _prefs.getString('user_role');
  if (cachedRole != null) {
    return cachedRole;
  }

  // Fetch from network
  try {
    final response = await _supabaseClient
        .from('users')
        .select('role')
        .eq('id', currentUser.id)
        .single();

    final role = response['role'] as String?;
    if (role != null) {
      await _prefs.setString('user_role', role);
    }
    return role;
  } catch (e) {
    logger.e('Error fetching user role: $e');
    return null;
  }
}
```

**Key principles:**
- Check cache before network requests
- Update cache after successful fetch
- Use SharedPreferences for simple key-value caching
- Use Drift for complex data caching

### Offline-First Pattern
**Frequency: Used in critical data services**

```dart
Future<int?> getCurrentUserSchoolId() async {
  final currentUser = _supabaseClient.auth.currentUser;
  if (currentUser == null) return null;

  final cachedSchoolId = _prefs.getInt('school_id');
  final connectivityResult = await Connectivity().checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none) && cachedSchoolId != null) {
    return cachedSchoolId;
  }

  try {
    final response = await _supabaseClient
        .from('users')
        .select('school_id')
        .eq('id', currentUser.id)
        .single();
    
    final schoolId = response['school_id'] as int?;
    if (schoolId != null) {
      await _prefs.setInt('school_id', schoolId);
    }
    return schoolId;
  } catch (e) {
    logger.e('Error fetching school_id: $e');
    return cachedSchoolId;
  }
}
```

**Key principles:**
- Check connectivity before network operations
- Return cached data when offline
- Fallback to cache on network errors
- Update cache when online

### Edge Function Invocation Pattern
**Frequency: Used for admin operations**

```dart
Future<User?> createUserViaEdgeFunction({
  required String email,
  required String password,
  required String role,
  required int schoolId,
  String? fullName,
}) async {
  try {
    final response = await _supabaseClient.functions.invoke(
      'create-user-admin',
      body: {
        'email': email,
        'password': password,
        'role': role,
        'school_id': schoolId,
        'full_name': fullName,
      },
    );

    if (response.data == null) {
      logger.e('Edge Function returned no data.');
      throw Exception('Failed to create user: Edge function returned no data.');
    }

    final responseData = response.data as Map<String, dynamic>;
    if (responseData.containsKey('error')) {
      logger.e('Error from Edge Function: ${responseData['error']}');
      throw Exception('Failed to create user: ${responseData['error']}');
    }
    
    return User.fromJson(responseData);
  } catch (e) {
    logger.e('Exception calling edge function: $e');
    throw Exception('Failed to create user: ${e.toString()}');
  }
}
```

**Key principles:**
- Use Edge Functions for privileged operations
- Check for null response data
- Handle error responses from functions
- Throw exceptions with context
- Log all errors

### Theme and Styling Pattern
**Frequency: Centralized theme configuration**

```dart
class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: defaultAccentColor,
      scaffoldBackgroundColor: appBackgroundColor,
      colorScheme: ColorScheme.light(
        primary: defaultAccentColor,
        secondary: accentTeachers,
        surface: cardBackgroundColor,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textDarkGrey, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textDarkGrey),
      ).apply(
        fontFamily: 'Poppins',
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  static Color getAccentColorForContext(String context) {
    switch (context.toLowerCase()) {
      case 'student':
        return iconColorStudents;
      case 'teacher':
        return iconColorTeachers;
      default:
        return defaultAccentColor;
    }
  }
}
```

**Key principles:**
- Centralized theme configuration
- Consistent color palette with semantic names
- Context-specific accent colors
- Rounded corners (12-20px) for modern look
- Subtle elevations (1.0-8.0)
- Poppins font family throughout

## Platform-Specific Patterns

### Windows Native Code
**Pattern: Win32 window management with DPI awareness**

```cpp
bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  Destroy();

  const wchar_t* window_class =
      WindowClassRegistrar::GetInstance()->GetWindowClass();

  const POINT target_point = {static_cast<LONG>(origin.x),
                              static_cast<LONG>(origin.y)};
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;

  HWND window = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
      Scale(size.width, scale_factor), Scale(size.height, scale_factor),
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  UpdateTheme(window);
  return OnCreate();
}
```

**Key principles:**
- DPI-aware scaling for high-DPI displays
- Theme detection from Windows registry
- Singleton pattern for window class registration
- Resource cleanup in destructors
- Virtual methods for subclass customization

### Android Plugin Registration
**Pattern: Auto-generated plugin registration with error handling**

```java
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new AppLinksPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin app_links", e);
    }
  }
}
```

**Key principles:**
- @Keep annotation to prevent ProGuard removal
- Try-catch for each plugin registration
- Logging with specific error context
- Static registration method

### TypeScript Proxy Service
**Pattern: Simple HTTP proxy with error handling**

```typescript
async function handler(req: Request): Promise<Response> {
  const url = new URL(req.url);
  
  if (url.pathname === "/health") {
    return new Response("OK", { status: 200 });
  }
  
  if (url.pathname.startsWith("/v1beta/")) {
    const targetUrl = `${GEMINI_API_BASE}${url.pathname}${url.search}`;
    
    try {
      const response = await fetch(targetUrl, {
        method: req.method,
        headers,
        body: req.body,
      });
      
      return new Response(response.body, {
        status: response.status,
        headers: response.headers,
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ error: "Forwarding failed", details: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }
  
  return new Response("Not Found", { status: 404 });
}
```

**Key principles:**
- Health check endpoint for monitoring
- Path-based routing
- Error responses with JSON format
- Proper HTTP status codes

## Best Practices

### Null Safety
- Use nullable types (?) for optional values
- Provide default values in fromJson constructors
- Use null-aware operators (?., ??, ??=)
- Check for null before accessing properties

### Async/Await
- Always use async/await for asynchronous operations
- Return Future<T> for async methods
- Handle errors with try-catch
- Use FutureBuilder in UI for async data

### Dependency Injection
- Constructor injection for all dependencies
- Use Provider for dependency access in widgets
- Initialize dependencies in main.dart
- Keep dependencies immutable (final)

### Logging
- Use logger package for all logging
- Log errors with context (logger.e)
- Log info for important events (logger.i)
- Log warnings for potential issues (logger.w)

### State Management
- Use Provider for app-wide state
- Use StatefulWidget for local UI state
- Minimize state scope
- Call notifyListeners() after state changes

### Code Reusability
- Extract common widgets into separate files
- Create utility functions for repeated logic
- Use mixins for shared behavior
- Leverage inheritance sparingly

### Performance
- Cache frequently accessed data
- Use const constructors where possible
- Lazy load data when appropriate
- Optimize list rendering with keys

### Security
- Never hardcode credentials
- Use environment variables for secrets
- Validate all user inputs
- Use RLS policies in Supabase
- Call Edge Functions for privileged operations
