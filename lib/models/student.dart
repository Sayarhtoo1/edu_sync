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
      id: map['id'] ?? 0,
      schoolId: map['school_id'] ?? 0,
      classId: map['class_id'],
      fullName: map['full_name'] ?? '',
      profilePhotoUrl: map['profile_photo_url'],
      dateOfBirth: DateTime.tryParse(map['date_of_birth'] ?? ''),
      gender: map['gender'],
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
