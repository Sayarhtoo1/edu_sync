import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/models/announcement.dart'; // Assuming this path for Announcement model

class InAppNotificationPopup extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onDismiss;

  const InAppNotificationPopup({
    super.key,
    required this.announcement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              announcement.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    onDismiss(); // Dismiss the popup before navigating
                    context.go('/parent/announcements'); // Navigate to announcements screen
                  },
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}