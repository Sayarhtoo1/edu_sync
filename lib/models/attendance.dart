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
      id: map['id'] as int?,
      classId: map['class_id'] as int, // Corrected to int
      studentId: map['student_id'] as int,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'Present', // Default if null, though DB should prevent null
      markedByTeacherId: map['marked_by_teacher_id'] as String?,
      updatedAt: map['updated_at'] == null ? null : DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Should not be sent for insert if auto-generated
      'class_id': classId,
      'student_id': studentId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'status': status, // status is now directly used
      'marked_by_teacher_id': markedByTeacherId,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
