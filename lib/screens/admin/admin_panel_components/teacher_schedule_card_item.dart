import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/models/schedule_summary.dart';
import 'package:edu_sync/models/timetable_status.dart'; // Import TimetableStatus
import 'package:edu_sync/screens/teacher/teacher_timetable_components/timetable_helpers.dart'; // For status colors/icons

class TeacherScheduleCardItem extends StatelessWidget {
  final ScheduleSummary summary;
  final AppLocalizations l10n;

  const TeacherScheduleCardItem({
    super.key,
    required this.summary,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Color statusColor = Colors.grey; // Default color
    IconData statusIcon = Icons.info_outline; // Default icon
    String statusText = l10n.noScheduleToday; // Default text

    if (summary.currentEntry != null) {
      statusColor = getTimetableColorForStatus(TimetableStatus.inProcess);
      statusIcon = getTimetableIconForStatus(TimetableStatus.inProcess);
      statusText = l10n.teacherTeaching(
        summary.teacherName ?? l10n.unnamedTeacher,
        summary.currentEntry!.subjectName,
        summary.currentEntry!.classId.toString(),
      );
    } else if (summary.nextEntry != null) {
      statusColor = getTimetableColorForStatus(TimetableStatus.upcoming);
      statusIcon = getTimetableIconForStatus(TimetableStatus.upcoming);
      statusText = l10n.teacherNextClass(
        summary.teacherName ?? l10n.unnamedTeacher,
        summary.nextEntry!.subjectName,
        summary.nextEntry!.classId.toString(),
      );
    } else if (summary.isFree) {
      statusColor = getTimetableColorForStatus(TimetableStatus.done); // Use 'done' color for free
      statusIcon = getTimetableIconForStatus(TimetableStatus.done);
      statusText = l10n.teacherFreeNow(summary.teacherName ?? l10n.unnamedTeacher);
    }

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withAlpha((255 * 0.2).round()),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.teacherName ?? l10n.unnamedTeacher,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    statusText,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}