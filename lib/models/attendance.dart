import 'package:intl/intl.dart'; // For date formatting in toMap

class Attendance {
  final int? id;
  final int classId; // Corrected to int
  final int studentId;
  final DateTime date;
  final String status; // Changed to non-nullable, as DB has a default and CHECK constraint
  final String? markedByTeacherId; // UUID String of the teacher
  final DateTime? updatedAt;

  Attendance({
    this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.status, // Changed from isPresent
    this.markedByTeacherId,
    this.updatedAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      classId: map['class_id'] ?? 0,
      studentId: map['student_id'] ?? 0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Present',
      markedByTeacherId: map['marked_by_teacher_id'],
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'class_id': classId,
      'student_id': studentId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'status': status,
      'marked_by_teacher_id': markedByTeacherId,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'class_id': classId,
      'student_id': studentId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'status': status,
      'marked_by_teacher_id': markedByTeacherId,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
