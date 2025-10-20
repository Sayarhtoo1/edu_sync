# Development Guidelines

## Code Quality Standards

### File Headers and Copyright
- Platform-specific native code (C++, C) includes copyright headers: `// Copyright 2013 The Flutter Authors. All rights reserved.`
- License references included in native platform files
- Dart files do not require copyright headers

### Code Formatting
- **Dart**: Follow standard Dart formatting conventions
  - Use `dart format` for consistent formatting
  - 2-space indentation
  - Line length typically 80-120 characters
  - Trailing commas for better formatting and diffs
- **C++**: Follow Flutter's C++ style guide
  - Include guards with full path: `#ifndef FLUTTER_SHELL_PLATFORM_...`
  - Namespace usage for organization
  - `constexpr` for compile-time constants
- **TypeScript/Deno**: Standard TypeScript conventions
  - 2-space indentation
  - Semicolons required
  - Explicit type annotations where beneficial

### Naming Conventions
- **Dart Classes**: PascalCase (e.g., `AuthService`, `UserRole`, `EncodableValue`)
- **Dart Files**: snake_case (e.g., `auth_service.dart`, `user_role.dart`)
- **Dart Variables/Functions**: camelCase (e.g., `getCurrentUser`, `schoolId`)
- **Dart Private Members**: Prefix with underscore (e.g., `_supabaseClient`, `_prefs`, `_cache`)
- **Constants**: 
  - Dart: lowerCamelCase for const variables (e.g., `kWindowClassName`)
  - C++: SCREAMING_SNAKE_CASE for macros (e.g., `DWMWA_USE_IMMERSIVE_DARK_MODE`)
- **Type Aliases**: PascalCase (e.g., `EncodableList`, `EncodableMap`)

### Documentation Standards
- **Dart**: Use `///` for public API documentation
- **C++**: Use `//` for inline comments, multi-line `/* */` for block comments
- **Function Documentation**: Describe purpose, parameters, and return values
- **Complex Logic**: Add inline comments explaining non-obvious behavior
- Example from C++ header:
  ```cpp
  /// Window attribute that enables dark mode window decorations.
  ///
  /// Redefined in case the developer's machine has a Windows SDK older than
  /// version 10.0.22000.0.
  ```

## Architectural Patterns

### Service Layer Pattern
- All business logic encapsulated in service classes
- Services injected via dependency injection (GetIt or Provider)
- Services are stateless; state managed by providers
- Example structure:
  ```dart
  class AuthService {
    final SupabaseClient _supabaseClient;
    final SharedPreferences _prefs;
    final NotificationService _notificationService;
    CacheService? _cache;
    
    AuthService({
      required SupabaseClient supabaseClient,
      required SharedPreferences sharedPreferences,
      required NotificationService notificationService,
    }) : _supabaseClient = supabaseClient,
         _prefs = sharedPreferences,
         _notificationService = notificationService;
  }
  ```

### Dependency Injection
- Constructor injection for required dependencies
- Named parameters with `required` keyword
- Optional dependencies can be set via setter methods
- Initializer lists for field assignment
- Example:
  ```dart
  void setCacheService(CacheService cache) {
    _cache = cache;
  }
  ```

### Error Handling
- Try-catch blocks for all async operations
- Logging errors with context using `logger.e()`
- Graceful degradation (e.g., fallback to cache on network failure)
- User-friendly error messages
- Example pattern:
  ```dart
  try {
    final response = await _supabaseClient.from('users').select();
    return users;
  } catch (e) {
    logger.e('Error fetching users: $e');
    if (_cache != null) {
      return await _cache!.getCachedUsers(schoolId);
    }
    return [];
  }
  ```

### Null Safety
- Strict null safety enabled (Dart 3.7.2+)
- Use `?` for nullable types
- Use `!` sparingly and only when certain value is non-null
- Prefer null-aware operators: `??`, `?.`, `??=`
- Example:
  ```dart
  final schoolId = response['school_id'] as int?;
  if (schoolId != null) {
    await _prefs.setInt('school_id', schoolId);
  }
  ```

### Async/Await Pattern
- All I/O operations are async
- Use `Future<T>` return types for async methods
- Await async calls sequentially when dependent
- Use `Future.wait()` for parallel independent operations
- Always handle errors in async code

## Data Management Patterns

### Model Classes
- Immutable data classes with final fields
- Factory constructors for JSON deserialization: `factory User.fromJson(Map<String, dynamic> map)`
- `copyWith` method for creating modified copies
- `toMap()` method for serialization
- Example structure:
  ```dart
  class User {
    final String id;
    final String role;
    final String? fullName;
    
    User({required this.id, required this.role, this.fullName});
    
    factory User.fromJson(Map<String, dynamic> map) {
      return User(
        id: map['id'] ?? '',
        role: map['role'] ?? 'user',
        fullName: map['full_name'],
      );
    }
    
    User copyWith({String? id, String? role, String? fullName}) {
      return User(
        id: id ?? this.id,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
      );
    }
    
    Map<String, dynamic> toMap() {
      return {'id': id, 'role': role, 'full_name': fullName};
    }
  }
  ```

### Caching Strategy
- Two-tier caching: SharedPreferences for simple values, CacheService for complex data
- Cache-first approach with network fallback
- Cache invalidation on data updates
- Offline-first architecture
- Example:
  ```dart
  // Try cache first
  String? cachedRole = _prefs.getString('user_role');
  if (cachedRole != null) return cachedRole;
  
  // Fetch from network and cache
  final role = response['role'] as String?;
  if (role != null) {
    await _prefs.setString('user_role', role);
  }
  ```

### Database Queries
- Use Supabase client for all database operations
- Chain query methods: `.select()`, `.eq()`, `.order()`, `.single()`
- Handle both list and single responses appropriately
- Always specify columns in select when possible
- Example:
  ```dart
  final response = await _supabaseClient
      .from('users')
      .select('role')
      .eq('id', currentUser.id)
      .single();
  ```

## Platform-Specific Patterns

### Native Platform Code (C++)
- Use opaque pointers for cross-boundary types: `typedef struct FlutterDesktopEngine* FlutterDesktopEngineRef;`
- Extern "C" blocks for C compatibility
- RTTI detection with preprocessor directives
- Platform-specific includes guarded by defines
- Resource management with RAII principles
- Example:
  ```cpp
  #if defined(__cplusplus)
  extern "C" {
  #endif
  
  typedef struct FlutterDesktopViewController* FlutterDesktopViewControllerRef;
  
  #if defined(__cplusplus)
  }
  #endif
  ```

### Flutter-Native Bridge
- Use method channels for platform communication
- Encodable values for data serialization
- Plugin registrar pattern for native plugins
- Lifecycle management with callbacks

### Proxy Services (Deno/TypeScript)
- Simple request forwarding pattern
- Health check endpoints: `/health`
- Error handling with JSON responses
- CORS and header management
- Example:
  ```typescript
  async function handler(req: Request): Promise<Response> {
    if (url.pathname === "/health") {
      return new Response("OK", { status: 200 });
    }
    
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
  ```

## Common Code Idioms

### Import Aliasing
- Use aliases to avoid naming conflicts
- Convention: `as app_<type>` for application models
- Example:
  ```dart
  import 'package:edu_sync/models/user.dart' as app_user;
  import 'package:supabase_flutter/supabase_flutter.dart';
  
  // Now can use both app_user.User and supabase User
  ```

### Logging Pattern
- Use centralized logger utility
- Log levels: `logger.i()` (info), `logger.w()` (warning), `logger.e()` (error)
- Include context in log messages
- Example:
  ```dart
  logger.i('User signed in, subscribing to announcements.');
  logger.w('Cannot subscribe: role=$role, schoolId=$schoolId');
  logger.e('Error fetching user role: $e');
  ```

### Connectivity Checking
- Check connectivity before network operations
- Graceful offline handling
- Example:
  ```dart
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none) && cachedData != null) {
    return cachedData;
  }
  ```

### Edge Function Invocation
- Use Supabase Functions for server-side operations
- Pass data as body object
- Check for error in response data
- Example:
  ```dart
  final response = await _supabaseClient.functions.invoke(
    'create-user-admin',
    body: {
      'email': email,
      'password': password,
      'role': role,
    },
  );
  
  if (response.data == null) {
    throw Exception('Edge function returned no data.');
  }
  
  final responseData = response.data as Map<String, dynamic>;
  if (responseData.containsKey('error')) {
    throw Exception('Failed: ${responseData['error']}');
  }
  ```

### File Upload Pattern
- Use Supabase Storage for file uploads
- Organize by entity type and ID
- Set cache control and upsert options
- Return public URL
- Example:
  ```dart
  final file = File(filePath);
  final storagePath = 'users/profile_photos/$userId/$fileName';
  await _supabaseClient.storage
      .from('edusync')
      .upload(storagePath, file, 
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
  
  final publicUrl = _supabaseClient.storage
      .from('edusync')
      .getPublicUrl(storagePath);
  ```

## Best Practices

### Security
- Never expose service role keys in client code
- Use Edge Functions for privileged operations
- Validate all user inputs
- Use RLS (Row Level Security) policies in Supabase
- Store sensitive data in environment variables

### Performance
- Cache frequently accessed data
- Use pagination for large datasets
- Lazy load data when possible
- Optimize database queries with proper indexes
- Use const constructors where applicable

### Testing
- Write unit tests for services
- Use mockito for mocking dependencies
- Test error scenarios and edge cases
- Maintain test utilities for common patterns

### Code Organization
- One class per file
- Group related files in directories
- Keep files focused and under 500 lines when possible
- Use barrel files (index exports) sparingly

### State Management
- Use Provider for app-wide state
- Keep state immutable
- Notify listeners on state changes
- Separate UI state from business logic

### Responsive Design
- Use PlatformAdaptiveScreen for mobile/desktop variants
- Implement responsive layouts with MediaQuery
- Test on multiple screen sizes
- Consider platform-specific UI patterns
