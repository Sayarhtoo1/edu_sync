import 'package:flutter/material.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/school_class.dart'; // Assuming Class model is needed for class name
import 'package:edu_sync/l10n/app_localizations.dart'; // For localization

class ChildOverviewCard extends StatelessWidget {
  final Student student;
  final SchoolClass? studentClass; // Optional, to display class name
  final VoidCallback? onTap; // Make the card clickable

  const ChildOverviewCard({
    super.key,
    required this.student,
    this.studentClass,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // TODO: Get actual class name from studentClass if available
    final String className = studentClass?.name ?? l10n.unassignedClass; // Use localized string

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // TODO: Display student profile photo
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueGrey[100], // Placeholder color
                child: Icon(Icons.person, size: 30, color: Colors.blueGrey[700]), // Placeholder icon
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${l10n.classLabel}: $className", // Localize "Class"
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    // TODO: Add quick status indicator (e.g., attendance)
                  ],
                ),
              ),
              // TODO: Add an arrow or indicator for clickability
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
