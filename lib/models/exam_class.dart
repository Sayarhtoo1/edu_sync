import 'package:flutter/material.dart';

class ExamClass {
  final String id;
  final String examId;
  final int classId;
  final DateTime examDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? venue;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamClass({
    required this.id,
    required this.examId,
    required this.classId,
    required this.examDate,
    this.startTime,
    this.endTime,
    this.venue,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamClass.fromMap(Map<String, dynamic> map) {
    return ExamClass(
      id: map['id'],
      examId: map['exam_id'],
      classId: map['class_id'],
      examDate: DateTime.parse(map['exam_date']),
      startTime: map['start_time'] != null ? _parseTimeOfDay(map['start_time']) : null,
      endTime: map['end_time'] != null ? _parseTimeOfDay(map['end_time']) : null,
      venue: map['venue'],
      instructions: map['instructions'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,
      'class_id': classId,
      'exam_date': examDate.toIso8601String().split('T')[0],
      'start_time': startTime != null ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00' : null,
      'end_time': endTime != null ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00' : null,
      'venue': venue,
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
