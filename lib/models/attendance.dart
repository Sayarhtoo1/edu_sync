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
  
  @ColumnInfo(name: 'is_present') // Ensure column name matches Supabase
  final bool isPresent; 
  final String? status; 
  @ColumnInfo(name: 'marked_by_teacher_id') // Ensure column name matches Supabase
  final String? markedByTeacherId; // UUID String of the teacher

  Attendance({
    this.id,
    required this.classId,
    required this.studentId,
    required this.date,
    required this.isPresent,
    this.status,
    this.markedByTeacherId,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      classId: map['class_id'] as int, // Corrected to int
      studentId: map['student_id'] as int,
      date: DateTime.parse(map['date'] as String), 
      isPresent: map['is_present'] as bool? ?? false, 
      status: map['status'] as String?, 
      markedByTeacherId: map['marked_by_teacher_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, 
      'class_id': classId,
      'student_id': studentId,
      'date': DateFormat('yyyy-MM-dd').format(date), 
      'is_present': isPresent,
      'status': status,
      'marked_by_teacher_id': markedByTeacherId,
    };
  }
}
