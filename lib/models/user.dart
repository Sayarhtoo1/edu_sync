class User {
  final String id;
  final String role;
  final String? profilePhotoUrl;
  final String? fullName;
  final int? schoolId;
  final String? email;
  final String? phoneNumber1;
  final String? phoneNumber2;
  final double? salary;

  User({
    required this.id,
    required this.role,
    this.profilePhotoUrl,
    this.fullName,
    this.schoolId,
    this.email,
    this.phoneNumber1,
    this.phoneNumber2,
    this.salary,
  });

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      role: map['role'] ?? 'user',
      profilePhotoUrl: map['profile_photo_url'],
      fullName: map['full_name'],
      schoolId: map['school_id'],
      email: map['email'],
      phoneNumber1: map['phone_number_1'] ?? map['phone_number'],
      phoneNumber2: map['phone_number_2'],
      salary: map['salary'] != null ? (map['salary'] as num).toDouble() : null,
    );
  }

  User copyWith({
    String? id,
    String? role,
    String? profilePhotoUrl,
    String? fullName,
    int? schoolId,
    String? email,
    String? phoneNumber1,
    String? phoneNumber2,
    double? salary,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      fullName: fullName ?? this.fullName,
      schoolId: schoolId ?? this.schoolId,
      email: email ?? this.email,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      salary: salary ?? this.salary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'profile_photo_url': profilePhotoUrl,
      'full_name': fullName,
      'school_id': schoolId,
      'email': email,
      'phone_number_1': phoneNumber1,
      'phone_number_2': phoneNumber2,
      'salary': salary,
    };
  }
}
