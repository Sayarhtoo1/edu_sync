import 'package:flutter/material.dart';
import 'package:edu_sync/models/timetable.dart';

enum TimetableStatus {
  upcoming,
  inProcess,
  done,
}

class TimetableStatusHelper {
  static TimetableStatus getStatusForTimetableEntry(Timetable entry, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = _getDayOfWeekAsInt(entry.dayOfWeek);
    final currentDay = now.weekday; // Monday is 1, Sunday is 7

    // Adjust currentDay to match 0-6 (Sunday-Saturday) if needed, or keep as 1-7 and adjust entryDay
    // For simplicity, let's assume entry.dayOfWeek is like "Monday", "Tuesday", etc.
    // and compare with now.weekday (1 for Monday, 7 for Sunday)

    // Convert entry.dayOfWeek to a comparable integer (e.g., 1 for Monday, 7 for Sunday)
    final int entryDayInt = convertDayOfWeekStringToInt(entry.dayOfWeek);

    // Calculate the DateTime for the entry's start and end times on the 'now' date
    final DateTime entryStartDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      entry.startTimeOfDay.hour,
      entry.startTimeOfDay.minute,
    );
    final DateTime entryEndDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      entry.endTimeOfDay.hour,
      entry.endTimeOfDay.minute,
    );

    // If the entry is for a future day of the week
    if (entryDayInt > currentDay) {
      return TimetableStatus.upcoming;
    }
    // If the entry is for a past day of the week
    if (entryDayInt < currentDay) {
      return TimetableStatus.done;
    }

    // If it's the current day
    if (now.isBefore(entryStartDateTime)) {
      return TimetableStatus.upcoming;
    } else if (now.isAfter(entryStartDateTime) && now.isBefore(entryEndDateTime)) {
      return TimetableStatus.inProcess;
    } else {
      return TimetableStatus.done;
    }
  }

  static int convertDayOfWeekStringToInt(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday': return 1;
      case 'tuesday': return 2;
      case 'wednesday': return 3;
      case 'thursday': return 4;
      case 'friday': return 5;
      case 'saturday': return 6;
      case 'sunday': return 7;
      default: return 0; // Should not happen
    }
  }

  // This helper is not used in the current implementation but might be useful for other contexts
  static int _getDayOfWeekAsInt(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 0; // Invalid day
    }
  }

  static bool isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) {
      return true;
    } else if (time1.hour == time2.hour) {
      return time1.minute > time2.minute;
    }
    return false;
  }
}
