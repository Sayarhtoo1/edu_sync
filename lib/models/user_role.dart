enum UserRole {
  Admin,
  Teacher,
  Parent,
  Manager,
  Donator;

  String get name {
    switch (this) {
      case UserRole.Admin:
        return 'Admin';
      case UserRole.Teacher:
        return 'Teacher';
      case UserRole.Parent:
        return 'Parent';
      case UserRole.Manager:
        return 'Manager';
      case UserRole.Donator:
        return 'Donator';
    }
  }

  static UserRole? fromString(String? roleString) {
    if (roleString == null) return null;
    switch (roleString) {
      case 'Admin':
        return UserRole.Admin;
      case 'Teacher':
        return UserRole.Teacher;
      case 'Parent':
        return UserRole.Parent;
      case 'Manager':
        return UserRole.Manager;
      case 'Donator':
        return UserRole.Donator;
      default:
        return null;
    }
  }
}