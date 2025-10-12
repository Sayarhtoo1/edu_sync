import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout: 2 columns on mobile, 4 on larger screens
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildActionCard(
                  'Create Exam',
                  'Schedule new exam',
                  Icons.add_circle_outline,
                  () => context.push('/exam-management/create'),
                  accentStudents,
                ),
                _buildActionCard(
                  'Manage Subjects',
                  'Add/edit subjects',
                  Icons.subject,
                  () => context.push('/admin/subject-management'),
                  Colors.purple,
                ),
                _buildActionCard(
                  'Exam Calendar',
                  'View schedule',
                  Icons.calendar_month,
                  () => context.push('/exam-calendar/1'),
                  Colors.blue,
                ),
                _buildActionCard(
                  'Templates',
                  'Exam templates',
                  Icons.content_copy,
                  () => context.push('/exam-templates/1'),
                  Colors.orange,
                ),
                _buildActionCard(
                  'Approvals',
                  'Review marks',
                  Icons.approval,
                  () => context.push('/marks-approval/1'),
                  Colors.green,
                ),
                _buildActionCard(
                  'Notifications',
                  'Preferences',
                  Icons.notifications,
                  () => context.push('/exam-notification-preferences'),
                  Colors.red,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap, Color color) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: textLightGrey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}