import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import '../../../models/timetable.dart' as timetable_model;
import '../../../models/school_class.dart' as app_class;
import 'timetable_helpers.dart'; // Import the helpers

class TimetableEntryCard extends StatelessWidget {
  const TimetableEntryCard({
    super.key,
    required this.entry,
    required this.classMap,
    required this.l10n,
    required this.selectedDate, // Pass selectedDate for status calculation
  });

  final timetable_model.Timetable entry;
  final Map<int, app_class.SchoolClass> classMap;
  final AppLocalizations l10n;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final status = getTimetableStatus(entry, selectedDate); // Use helper
    final color = getTimetableColorForStatus(status); // Use helper
    final statusText = getTimetableStatusText(status, l10n); // Use helper
    final iconData = getTimetableIconForStatus(status); // Use helper

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill-shaped status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.white, size: 16.0),
                const SizedBox(width: 4.0),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0), // Space between pill and card
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 4.0,
                  height: 80.0, // This height might need adjustment based on content
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(width: 8.0), // Space between line and card
                Expanded(
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.subjectName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${l10n.classLabel}: ${classMap[entry.classId]?.name ?? l10n.unknown_class}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${l10n.time}: ${entry.startTimeString} - ${entry.endTimeString}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}