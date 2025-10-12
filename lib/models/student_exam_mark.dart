class StudentExamMark {
  final String id;
  final String examId;
  final int studentId;
  final String subjectId;
  final int marksObtained;
  final int totalMarks;
  final String? gradeId;
  final DateTime createdAt;

  StudentExamMark({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.subjectId,
    required this.marksObtained,
    required this.totalMarks,
    this.gradeId,
    required this.createdAt,
  });

  factory StudentExamMark.fromJson(Map<String, dynamic> json) {
    return StudentExamMark(
      id: json['id'],
      examId: json['exam_id'],
      studentId: json['student_id'],
      subjectId: json['subject_id'],
      marksObtained: json['marks_obtained'],
      totalMarks: json['total_marks'],
      gradeId: json['grade_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'subject_id': subjectId,
      'marks_obtained': marksObtained,
      'total_marks': totalMarks,
      'grade_id': gradeId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get percentage => totalMarks > 0 ? (marksObtained / totalMarks) * 100 : 0.0;
}
