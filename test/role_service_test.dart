import 'package:flutter_test/flutter_test.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/role_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock AuthService for testing RoleService
class MockAuthService extends AuthService {
  String? mockRole;

  @override
  Future<String?> getUserRole() async {
    return mockRole;
  }

  // Add mock implementations for other AuthService methods if needed,
  // though for RoleService tests, only getUserRole is critical.
  @override
  User? getCurrentUser() {
    if (mockRole != null) {
      return User(
          id: 'mock_user_id',
          appMetadata: {},
          userMetadata: {'role': mockRole!},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String());
    }
    return null;
  }
}

void main() {
  late RoleService roleService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    // It's better to inject the mock AuthService into RoleService.
    // For this example, we'll assume RoleService can be instantiated
    // or its AuthService dependency can be replaced for testing.
    // If RoleService directly instantiates AuthService(), this test will be harder.
    // Let's modify RoleService to accept AuthService in constructor for testability.
    // For now, we'll proceed assuming we can test RoleService by controlling
    // the behavior of the AuthService it uses, perhaps by modifying RoleService
    // to use a passed-in AuthService instance or a global mock.

    // This is a simplified setup. In a real app, ensure RoleService uses the mock.
    // One way: Modify RoleService to take AuthService in its constructor.
    // e.g., class RoleService { final AuthService _authService; RoleService(this._authService); }
    // Then in test: roleService = RoleService(mockAuthService);
    // For this example, we'll assume direct instantiation and rely on overriding getUserRole.
    roleService = RoleService(mockAuthService); 
  });

  group('RoleService', () {
    test('isAdmin returns true for Admin role', () async {
      mockAuthService.mockRole = 'Admin';
      expect(await roleService.isAdmin(), isTrue);
    });

    test('isTeacher returns true for Teacher role', () async {
      mockAuthService.mockRole = 'Teacher';
      expect(await roleService.isTeacher(), isTrue);
    });

    test('isParent returns true for Parent role', () async {
      mockAuthService.mockRole = 'Parent';
      expect(await roleService.isParent(), isTrue);
    });

    test('isAdmin returns false for non-Admin role', () async {
      mockAuthService.mockRole = 'Teacher';
      expect(await roleService.isAdmin(), isFalse);
    });
  });
}
