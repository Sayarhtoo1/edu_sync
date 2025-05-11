import 'auth_service.dart';

class RoleService {
  final AuthService _authService;

  RoleService(this._authService);

  bool isAdmin() {
    return _authService.getUserRole() == 'Admin';
  }

  bool isTeacher() {
    return _authService.getUserRole() == 'Teacher';
  }

  bool isParent() {
    return _authService.getUserRole() == 'Parent';
  }
}
