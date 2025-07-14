import 'user.dart';

class Parent extends User {
  Parent({
    required super.id,
    super.profilePhotoUrl,
    super.fullName,
    super.schoolId,
  }) : super(
          role: 'Parent',
        );

  // Add fromMap and copyWith if needed for Parent-specific properties
}
