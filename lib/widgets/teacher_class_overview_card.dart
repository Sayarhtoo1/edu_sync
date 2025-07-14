import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart'; // Import Class model
import 'package:edu_sync/l10n/app_localizations.dart'; // For localization

class TeacherClassOverviewCard extends StatelessWidget {
  final SchoolClass classItem;
  final int studentCount; // To display the number of students in the class
  final VoidCallback? onTap; // Make the card clickable

  const TeacherClassOverviewCard({
    super.key,
    required this.classItem,
    required this.studentCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon representing a class
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal[100], // Placeholder color
                child: Icon(Icons.class_, size: 30, color: Colors.teal[700]), // Placeholder icon
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${l10n.students}: $studentCount", // Localize "Students"
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Arrow or indicator for clickability
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
