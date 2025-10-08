class Exam {
  final String id;
  final int classId;
  final int schoolId;
  final String name;
  final DateTime examDate;
  final String examinerName;
  final DateTime createdAt;
  final String? description;
  final int? maxMarks;

  Exam({
    required this.id,
    required this.classId,
    required this.schoolId,
    required this.name,
    required this.examDate,
    required this.examinerName,
    required this.createdAt,
    this.description,
    this.maxMarks,
  });

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      classId: map['class_id'] is String ? int.parse(map['class_id']) : map['class_id'],
      schoolId: map['school_id'] is String ? int.parse(map['school_id']) : map['school_id'],
      name: map['name'],
      examDate: DateTime.parse(map['exam_date']),
      examinerName: map['examiner_name'],
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
      maxMarks: map['max_marks'] != null ? (map['max_marks'] is String ? int.parse(map['max_marks']) : map['max_marks']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'school_id': schoolId,
      'name': name,
      'exam_date': examDate.toIso8601String(),
      'examiner_name': examinerName,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }
}
