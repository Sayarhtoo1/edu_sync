import 'package:flutter/material.dart'; // Added for TimeOfDay
// import '../type_converters.dart'; // Not strictly needed here if TimeOfDay is stored as String

// Helper to format TimeOfDay to HH:mm string
String _formatTimeOfDay(TimeOfDay tod) {
  final hour = tod.hour.toString().padLeft(2, '0');
  final minute = tod.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// Helper to parse HH:mm string to TimeOfDay
TimeOfDay _parseTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}


class Timetable {
  final int id; 
  final int classId; // Corrected to int
  
  final TimeOfDay startTimeOfDay; 
  final TimeOfDay endTimeOfDay;

  final String startTimeString; 
  final String endTimeString;   
  
  final String dayOfWeek; // Consider using int (0-6) for easier sorting/filtering
  final String subjectName;
  final String? teacherId; // UUID String

  Timetable({
    required this.id,
    required this.classId,
    required this.startTimeOfDay,
    required this.endTimeOfDay,
    required this.dayOfWeek,
    required this.subjectName,
    this.teacherId,
  }) : startTimeString = _formatTimeOfDay(startTimeOfDay),
       endTimeString = _formatTimeOfDay(endTimeOfDay);

  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable( 
      id: map['id'] as int, 
      classId: map['class_id'] as int, // Corrected to int
      startTimeOfDay: _parseTimeOfDay(map['start_time'] as String), 
      endTimeOfDay: _parseTimeOfDay(map['end_time'] as String),   
      dayOfWeek: map['day_of_week'] as String,
      subjectName: map['subject_name'] as String,
      teacherId: map['teacher_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Usually not included for inserts if auto-generated by DB
      'class_id': classId,
      'start_time': startTimeString, 
      'end_time': endTimeString,     
      'day_of_week': dayOfWeek,
      'subject_name': subjectName,
      'teacher_id': teacherId,
    };
  }
}
