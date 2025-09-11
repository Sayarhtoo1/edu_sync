import 'package:edu_sync/models/user_role.dart';

import 'auth_service.dart';

class RoleService {
  final AuthService _authService;

  RoleService(this._authService);

  Future<bool> isAdmin() async {
    final role = await _authService.getUserRole();
    return role == UserRole.Admin.name;
  }

  Future<bool> isTeacher() async {
    final role = await _authService.getUserRole();
    return role == UserRole.Teacher.name;
  }

  Future<bool> isParent() async {
    final role = await _authService.getUserRole();
    return role == UserRole.Parent.name;
  }

  Future<bool> isManager() async {
    final role = await _authService.getUserRole();
    return role == UserRole.Manager.name;
  }
}
