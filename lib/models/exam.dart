import 'exam_class.dart';

class Exam {
  final String id;
  final int schoolId;
  final String name;
  final String? examType;
  final String examinerName;
  final DateTime createdAt;
  final String? description;
  final int? maxMarks;
  final List<ExamClass>? examClasses;

  Exam({
    required this.id,
    required this.schoolId,
    required this.name,
    this.examType,
    required this.examinerName,
    required this.createdAt,
    this.description,
    this.maxMarks,
    this.examClasses,
  });

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      schoolId: map['school_id'] is String ? int.parse(map['school_id']) : map['school_id'],
      name: map['name'],
      examType: map['exam_type'],
      examinerName: map['examiner_name'],
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
      maxMarks: map['max_marks'] != null ? (map['max_marks'] is String ? int.parse(map['max_marks']) : map['max_marks']) : null,
      examClasses: map['exam_classes'] != null ? (map['exam_classes'] as List).map((e) => ExamClass.fromMap(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'exam_type': examType,
      'examiner_name': examinerName,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'max_marks': maxMarks,
    };
  }

  // Backward compatibility helpers
  int get classId => examClasses?.first.classId ?? 0;
  DateTime get examDate => examClasses?.first.examDate ?? createdAt;
}
