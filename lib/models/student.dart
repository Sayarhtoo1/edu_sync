class Student {
  final int id; // Assuming student ID itself remains int
  final int schoolId;
  final int? classId; // Corrected to int?
  final String fullName;
  final String? profilePhotoUrl;
  final DateTime? dateOfBirth;
  final String? gender; // Added gender field
  // Add other student-specific fields as needed

  Student({
    required this.id,
    required this.schoolId,
    this.classId, 
    required this.fullName,
    this.profilePhotoUrl,
    this.dateOfBirth,
    this.gender, // Added to constructor
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int,
      schoolId: map['school_id'] as int,
      classId: map['class_id'] as int?, 
      fullName: map['full_name'] as String,
      profilePhotoUrl: map['profile_photo_url'] as String?,
      dateOfBirth: map['date_of_birth'] != null ? DateTime.tryParse(map['date_of_birth'] as String) : null,
      gender: map['gender'] as String?, // Added gender from map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'class_id': classId,
      'full_name': fullName,
      'profile_photo_url': profilePhotoUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender, // Added gender to map
    };
  }
  
  Student copyWith({
    int? id,
    int? schoolId,
    int? classId, 
    String? fullName,
    String? profilePhotoUrl,
    DateTime? dateOfBirth,
    String? gender, // Added gender to copyWith
  }) {
    return Student(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      fullName: fullName ?? this.fullName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}
