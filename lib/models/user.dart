import 'package:floor/floor.dart';


@entity
class User {
  @primaryKey
  final String id; // Changed to String to match Supabase UUID
  final String role;
  final String? profilePhotoUrl;
  final String? fullName; // Changed from name to fullName for clarity
  final int? schoolId; // Added schoolId

  User({
    required this.id,
    required this.role,
    this.profilePhotoUrl,
    this.fullName,
    this.schoolId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      role: map['role'] as String,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      fullName: map['full_name'] as String?,
      schoolId: map['school_id'] as int?,
    );
  }

  // Add copyWith for easier updates
  User copyWith({
    String? id,
    String? role,
    String? profilePhotoUrl,
    String? fullName,
    int? schoolId,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      fullName: fullName ?? this.fullName,
      schoolId: schoolId ?? this.schoolId,
    );
  }
}
