class Student {
  final int id;
  final int schoolId;
  final int? classId;
  final String fullName;
  final String? profilePhotoUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phoneNumber1;
  final String? phoneNumber2;

  Student({
    required this.id,
    required this.schoolId,
    this.classId, 
    required this.fullName,
    this.profilePhotoUrl,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber1,
    this.phoneNumber2,
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
      phoneNumber1: map['phone_number_1'] ?? map['guardian_phone'],
      phoneNumber2: map['phone_number_2'],
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
      'gender': gender,
      'phone_number_1': phoneNumber1,
      'phone_number_2': phoneNumber2,
    };
  }
  
  Student copyWith({
    int? id,
    int? schoolId,
    int? classId,
    bool clearClassId = false,
    String? fullName,
    String? profilePhotoUrl,
    bool clearProfilePhotoUrl = false,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    String? gender,
    bool clearGender = false,
    String? phoneNumber1,
    bool clearPhoneNumber1 = false,
    String? phoneNumber2,
    bool clearPhoneNumber2 = false,
  }) {
    return Student(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: clearClassId ? null : (classId ?? this.classId),
      fullName: fullName ?? this.fullName,
      profilePhotoUrl: clearProfilePhotoUrl ? null : (profilePhotoUrl ?? this.profilePhotoUrl),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      gender: clearGender ? null : (gender ?? this.gender),
      phoneNumber1: clearPhoneNumber1 ? null : (phoneNumber1 ?? this.phoneNumber1),
      phoneNumber2: clearPhoneNumber2 ? null : (phoneNumber2 ?? this.phoneNumber2),
    );
  }
}
