import 'package:floor/floor.dart';
import 'package:intl/intl.dart'; // For date formatting in toMap
import '../type_converters.dart'; // Import DateTimeConverter

@Entity(tableName: 'attendance') // Use const constructor for @Entity, ensure table name matches Supabase
class Attendance {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  @ColumnInfo(name: 'class_id')
  final int classId; // Corrected to int
  @ColumnInfo(name: 'student_id')
  final int studentId;

  @TypeConverters([DateTimeConverter])
  final DateTime date;

  // Removed isPresent, status is now the source of truth
  final String status; // Changed to non-nullable, as DB has a default and CHECK constraint
  @ColumnInfo(name: 'marked_by_teacher_id') // Ensure column name matches Supabase
  final String? markedByTeacherId; // UUID String of the teacher

  Attendance({
    this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.status, // Changed from isPresent
    this.markedByTeacherId,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      classId: map['class_id'] as int, // Corrected to int
      studentId: map['student_id'] as int,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'Present', // Default if null, though DB should prevent null
      markedByTeacherId: map['marked_by_teacher_id'] as String?,
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
    };
  }
}
