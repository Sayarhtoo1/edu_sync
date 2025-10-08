class Grade {
  final String id;
  final String schoolId;
  final String gradeName;
  final int minPercentage;
  final int maxPercentage;
  final String? remarks;
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.schoolId,
    required this.gradeName,
    required this.minPercentage,
    required this.maxPercentage,
    this.remarks,
    required this.createdAt,
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      schoolId: map['school_id'],
      gradeName: map['grade_name'],
      minPercentage: map['min_percentage'],
      maxPercentage: map['max_percentage'],
      remarks: map['remarks'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'grade_name': gradeName,
      'min_percentage': minPercentage,
      'max_percentage': maxPercentage,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
