import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import '../../../models/timetable.dart' as timetable_model;
import '../../../models/timetable_status.dart';

TimetableStatus getTimetableStatus(timetable_model.Timetable entry, DateTime selectedDate) {
  final now = DateTime.now();
  final startTime = DateFormat('HH:mm').parse(entry.startTimeString);
  final endTime = DateFormat('HH:mm').parse(entry.endTimeString);
  final startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
  final endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);

  if (now.isBefore(startDateTime)) {
    return TimetableStatus.upcoming;
  } else if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
    return TimetableStatus.inProcess;
  } else {
    return TimetableStatus.done;
  }
}

String getTimetableStatusText(TimetableStatus status, AppLocalizations l10n) {
  switch (status) {
    case TimetableStatus.upcoming:
      return l10n.upcoming;
    case TimetableStatus.inProcess:
      return l10n.in_process;
    case TimetableStatus.done:
      return l10n.done;
  }
}

Color getTimetableColorForStatus(TimetableStatus status) {
  switch (status) {
    case TimetableStatus.upcoming:
      return Colors.blue;
    case TimetableStatus.inProcess:
      return Colors.green;
    case TimetableStatus.done:
      return Colors.grey;
  }
}

IconData getTimetableIconForStatus(TimetableStatus status) {
  switch (status) {
    case TimetableStatus.upcoming:
      return Icons.schedule;
    case TimetableStatus.inProcess:
      return Icons.play_arrow;
    case TimetableStatus.done:
      return Icons.check_circle;
  }
}