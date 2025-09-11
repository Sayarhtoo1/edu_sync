import 'package:flutter_test/flutter_test.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/role_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'role_service_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late RoleService roleService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    roleService = RoleService(mockAuthService);
  });

  group('RoleService', () {
    test('isAdmin returns true for Admin role', () async {
      when(mockAuthService.getUserRole()).thenAnswer((_) async => 'Admin');
      expect(await roleService.isAdmin(), isTrue);
    });

    test('isTeacher returns true for Teacher role', () async {
      when(mockAuthService.getUserRole()).thenAnswer((_) async => 'Teacher');
      expect(await roleService.isTeacher(), isTrue);
    });

    test('isParent returns true for Parent role', () async {
      when(mockAuthService.getUserRole()).thenAnswer((_) async => 'Parent');
      expect(await roleService.isParent(), isTrue);
    });

    test('isAdmin returns false for non-Admin role', () async {
      when(mockAuthService.getUserRole()).thenAnswer((_) async => 'Teacher');
      expect(await roleService.isAdmin(), isFalse);
    });
  });
}
