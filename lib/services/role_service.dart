import 'auth_service.dart';

class RoleService {
  final AuthService _authService;

  RoleService(this._authService);

  Future<bool> isAdmin() async {
    final role = await _authService.getUserRole();
    return role == 'Admin';
  }

  Future<bool> isTeacher() async {
    final role = await _authService.getUserRole();
    return role == 'Teacher';
  }

  Future<bool> isParent() async {
    final role = await _authService.getUserRole();
    return role == 'Parent';
  }
}
