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
  final String className; // Added class name
  
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
    required this.className, // Added class name
    required this.startTimeOfDay,
    required this.endTimeOfDay,
    required this.dayOfWeek,
    required this.subjectName,
    this.teacherId,
  }) : startTimeString = _formatTimeOfDay(startTimeOfDay),
       endTimeString = _formatTimeOfDay(endTimeOfDay);

  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      id: map['id'] ?? 0,
      classId: map['class_id'] ?? 0,
      className: map['class_name'] ?? 'Unknown Class', // Populate class name
      startTimeOfDay: _parseTimeOfDay(map['start_time'] ?? '00:00'),
      endTimeOfDay: _parseTimeOfDay(map['end_time'] ?? '00:00'),
      dayOfWeek: map['day_of_week'] ?? '',
      subjectName: map['subject_name'] ?? '',
      teacherId: map['teacher_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'start_time': startTimeString, 
      'end_time': endTimeString,     
      'day_of_week': dayOfWeek,
      'subject_name': subjectName,
      'teacher_id': teacherId,
    };
  }
}
