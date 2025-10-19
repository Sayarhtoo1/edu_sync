import 'package:flutter/material.dart';
class Subject {
  final String id;
  final String name;
  final int? classId;
  final int schoolId;
  final DateTime createdAt;
  final String? code;
  final int? maxMarks;
  final int? passingMarks;
  final String? parentSubjectId;
  final bool isSubSubject;
  final int displayOrder;
  final List<Subject>? subSubjects;

  Subject({
    required this.id,
    required this.name,
    this.classId,
    required this.schoolId,
    required this.createdAt,
    this.code,
    this.maxMarks,
    this.passingMarks,
    this.parentSubjectId,
    this.isSubSubject = false,
    this.displayOrder = 0,
    this.subSubjects,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      classId: map['class_id'],
      schoolId: map['school_id'],
      createdAt: DateTime.parse(map['created_at']),
      code: map['code'],
      maxMarks: map['max_marks'],
      passingMarks: map['passing_marks'],
      parentSubjectId: map['parent_subject_id'],
      isSubSubject: map['is_sub_subject'] ?? false,
      displayOrder: map['display_order'] ?? 0,
      subSubjects: map['sub_subjects'] != null ? (map['sub_subjects'] as List).map((e) => Subject.fromMap(e)).toList() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
      'school_id': schoolId,
      'created_at': createdAt.toIso8601String(),
      'code': code,
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'parent_subject_id': parentSubjectId,
      'is_sub_subject': isSubSubject,
      'display_order': displayOrder,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
      'school_id': schoolId,
      'created_at': createdAt.toIso8601String(),
      'code': code,
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
    };
  }

  bool get hasSubSubjects => subSubjects != null && subSubjects!.isNotEmpty;

  int get totalMaxMarks {
    if (hasSubSubjects) {
      return subSubjects!.fold(0, (sum, sub) => sum + (sub.maxMarks ?? 0));
    }
    return maxMarks ?? 0;
  }

  double get passingPercentage {
    if (maxMarks == null || passingMarks == null || maxMarks == 0) return 0.0;
    return (passingMarks! / maxMarks!) * 100;
  }

  Color getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green.shade600;
    if (percentage >= 80) return Colors.blue.shade600;
    if (percentage >= 70) return Colors.orange.shade600;
    if (percentage >= 60) return Colors.yellow.shade600;
    return Colors.red.shade600;
  }
}
