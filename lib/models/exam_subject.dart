class ExamSubject {
  final String id;
  final String examId;
  final String subjectId;
  final int maxMarks;
  final int passingMarks;
  final DateTime createdAt;

  ExamSubject({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.maxMarks,
    required this.passingMarks,
    required this.createdAt,
  });

  factory ExamSubject.fromMap(Map<String, dynamic> map) {
    return ExamSubject(
      id: map['id'],
      examId: map['exam_id'],
      subjectId: map['subject_id'],
      maxMarks: map['max_marks'],
      passingMarks: map['passing_marks'],
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
      'created_at': createdAt.toIso8601String(),
    };
  }
}
