import 'user.dart';

class Teacher extends User {
  Teacher({
    required super.id,
    super.profilePhotoUrl,
    super.fullName,
    super.schoolId,
  }) : super(
          role: 'Teacher',
        );

  // Add fromMap and copyWith if needed for Teacher-specific properties,
  // or rely on User's fromMap/copyWith if no Teacher-specific fields exist beyond User.
}
