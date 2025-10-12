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

  Subject({
    required this.id,
    required this.name,
    this.classId,
    required this.schoolId,
    required this.createdAt,
    this.code,
    this.maxMarks,
    this.passingMarks,
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
