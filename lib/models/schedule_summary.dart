import 'timetable.dart' as timetable_model;

class ScheduleSummary {
  final timetable_model.Timetable? currentEntry;
  final timetable_model.Timetable? nextEntry;
  final bool isFree;
  final String? teacherName; // Optional, for admin dashboard

  ScheduleSummary({
    this.currentEntry,
    this.nextEntry,
    this.isFree = true,
    this.teacherName,
  });
}