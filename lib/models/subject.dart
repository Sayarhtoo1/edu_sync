import 'package:flutter/material.dart';
class Subject {
  final String id;
  final String name;
  final String classId;
  final String schoolId;
  final DateTime createdAt;
  final int? maxMarks;
  final int? passingMarks;
  final List<GradeScale>? gradeScale;

  Subject({
    required this.id,
    required this.name,
    required this.classId,
    required this.schoolId,
    required this.createdAt,
    this.maxMarks,
    this.passingMarks,
    this.gradeScale,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      classId: map['class_id'],
      schoolId: map['school_id'],
      createdAt: DateTime.parse(map['created_at']),
      maxMarks: map['max_marks'],
      passingMarks: map['passing_marks'],
      gradeScale: map['grade_scale'] != null
          ? (map['grade_scale'] as List<dynamic>)
              .map((g) => GradeScale.fromMap(g as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
      'school_id': schoolId,
      'created_at': createdAt.toIso8601String(),
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'grade_scale': gradeScale?.map((g) => g.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
      'school_id': schoolId,
      'created_at': createdAt.toIso8601String(),
      'max_marks': maxMarks,
      'passing_marks': passingMarks,
      'grade_scale': gradeScale?.map((g) => g.toJson()).toList(),
    };
  }

  // Helper method to calculate passing percentage
  double get passingPercentage {
    if (maxMarks == null || passingMarks == null) return 0.0;
    return (passingMarks! / maxMarks!) * 100;
  }

  // Get grade color based on percentage
  Color getGradeColor(double percentage) {
    if (gradeScale == null || gradeScale!.isEmpty) {
      // Default color scheme
      if (percentage >= 90) return Colors.green.shade600;
      if (percentage >= 80) return Colors.blue.shade600;
      if (percentage >= 70) return Colors.orange.shade600;
      if (percentage >= 60) return Colors.yellow.shade600;
      return Colors.red.shade600;
    }

    for (final grade in gradeScale!) {
      if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
        return grade.color;
      }
    }
    return Colors.grey.shade600;
  }
}

class GradeScale {
  final String grade;
  final int minPercentage;
  final int maxPercentage;
  final Color color;
  final String? description;

  GradeScale({
    required this.grade,
    required this.minPercentage,
    required this.maxPercentage,
    required this.color,
    this.description,
  });

  factory GradeScale.fromMap(Map<String, dynamic> map) {
    return GradeScale(
      grade: map['grade'],
      minPercentage: map['min_percentage'],
      maxPercentage: map['max_percentage'],
      color: Color(map['color'] ?? 0xFF666666),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'min_percentage': minPercentage,
      'max_percentage': maxPercentage,
      'color': color.value,
      'description': description,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'min_percentage': minPercentage,
      'max_percentage': maxPercentage,
      'color': color.value,
      'description': description,
    };
  }
}