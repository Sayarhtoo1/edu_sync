class ExamSubject {
  final String id;
  final String examId;
  final String subjectId;
  final int maxMarks;
  final int passingMarks;
  final int? distinctionMarks;
  final String? examinerId;
  final bool isOptional;
  final double weightage;
  final DateTime createdAt;

  ExamSubject({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.maxMarks,
    required this.passingMarks,
    this.distinctionMarks,
    this.examinerId,
    this.isOptional = false,
    this.weightage = 100.0,
    required this.createdAt,
  });

  factory ExamSubject.fromMap(Map<String, dynamic> map) {
    return ExamSubject(
      id: map['id'],
      examId: map['exam_id'],
      subjectId: map['subject_id'],
      maxMarks: map['max_marks'],
      passingMarks: map['passing_marks'],
      distinctionMarks: map['distinction_marks'],
      examinerId: map['examiner_id'],
      isOptional: map['is_optional'] ?? false,
      weightage: map['weightage'] != null ? (map['weightage'] is int ? (map['weightage'] as int).toDouble() : map['weightage']) : 100.0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,
      'subject_id': subjectId,
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'distinction_marks': distinctionMarks,
      'examiner_id': examinerId,
      'is_optional': isOptional,
      'weightage': weightage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get hasDistinction => distinctionMarks != null;
}
