import 'package:flutter/material.dart'; // For IconData, Color, etc.
import 'package:intl/intl.dart'; // For DateFormat
import '../models/schedule_summary.dart';
import '../models/timetable.dart' as timetable_model;
import '../models/timetable_status.dart';
import '../models/user.dart'; // For User model, assuming Teacher extends User or similar
import '../screens/teacher/teacher_timetable_components/timetable_helpers.dart'; // For getTimetableStatus
import 'timetable_service.dart';
import 'auth_service.dart';
import 'user_service.dart'; // Assuming a UserService to fetch teachers

class ScheduleSummaryService {
  final TimetableService _timetableService;
  final AuthService _authService;
  final UserService _userService; // Assuming UserService is available

  ScheduleSummaryService(this._timetableService, this._authService, this._userService);

  Future<ScheduleSummary> getDailyScheduleSummary(String userId, DateTime date) async {
    final allEntries = await _timetableService.getTimetableForTeacher(userId);
    final selectedDayName = DateFormat('EEEE').format(date);
    final entriesForSelectedDay = allEntries
        .where((entry) => entry.dayOfWeek == selectedDayName)
        .toList();

    entriesForSelectedDay.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));

    timetable_model.Timetable? currentEntry;
    timetable_model.Timetable? nextEntry;
    bool isFree = true;

    for (var entry in entriesForSelectedDay) {
      final status = getTimetableStatus(entry, date);
      if (status == TimetableStatus.inProcess) {
        currentEntry = entry;
        isFree = false;
        break; // Found current, no need to check further for current
      } else if (status == TimetableStatus.upcoming && nextEntry == null) {
        nextEntry = entry;
        isFree = false;
      }
    }

    // If no current, find the first upcoming
    if (currentEntry == null && nextEntry == null) {
      for (var entry in entriesForSelectedDay) {
        final status = getTimetableStatus(entry, date);
        if (status == TimetableStatus.upcoming) {
          nextEntry = entry;
          isFree = false;
          break;
        }
      }
    }

    return ScheduleSummary(
      currentEntry: currentEntry,
      nextEntry: nextEntry,
      isFree: isFree,
    );
  }

  Future<List<ScheduleSummary>> getAllTeachersScheduleSummary(DateTime date) async {
    final allTeachers = await _userService.getTeachers(); // Assuming this method exists
    List<ScheduleSummary> summaries = [];

    for (var teacher in allTeachers) {
      final summary = await getDailyScheduleSummary(teacher.id!, date);
      summaries.add(ScheduleSummary(
        currentEntry: summary.currentEntry,
        nextEntry: summary.nextEntry,
        isFree: summary.isFree,
        teacherName: teacher.fullName, // Using fullName from app_user.User
      ));
    }
    return summaries;
  }
}