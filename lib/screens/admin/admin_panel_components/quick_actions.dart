import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/admin/add_edit_student_screen.dart';
import 'package:edu_sync/screens/admin/add_edit_parent_screen.dart';

class QuickActionsSection extends StatelessWidget {
  final int schoolId;
  const QuickActionsSection({super.key, required this.schoolId});

  Widget _buildQuickActionItem(BuildContext context, TextTheme textTheme, String title, IconData icon, Color bgColor, Color iconBgColor, Color iconFgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.08 * 255).round()),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBgColor,
              child: Icon(icon, color: iconFgColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final actions = [
      {
        'title': l10n.manageFormsAction,
        'icon': Icons.folder_open_outlined,
        'bgColor': Colors.green.withAlpha(100),
        'iconBgColor': Colors.green.shade100,
        'iconFgColor': Colors.green.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCustomFormsScreen())),
      },
      {
        'title': l10n.announcementsAction,
        'icon': Icons.campaign_outlined,
        'bgColor': Colors.purple.withAlpha(100),
        'iconBgColor': Colors.purple.shade100,
        'iconFgColor': Colors.purple.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
      },
      {
        'title': l10n.teacherTimetableAction,
        'icon': Icons.schedule,
        'bgColor': Colors.blue.withAlpha(100),
        'iconBgColor': Colors.blue.shade100,
        'iconFgColor': Colors.blue.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
      },
      {
        'title': l10n.markAttendanceTitle,
        'icon': Icons.check_circle_outline,
        'bgColor': Colors.green.withAlpha(100),
        'iconBgColor': Colors.green.shade100,
        'iconFgColor': Colors.green.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen())),
      },
      {
        'title': l10n.addStudent,
        'icon': Icons.person_add,
        'bgColor': Colors.orange.withAlpha(100),
        'iconBgColor': Colors.orange.shade100,
        'iconFgColor': Colors.orange.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditStudentScreen(schoolId: schoolId))),
      },
      {
        'title': l10n.addParent,
        'icon': Icons.person_add_alt_1,
        'bgColor': Colors.teal.withAlpha(100),
        'iconBgColor': Colors.teal.shade100,
        'iconFgColor': Colors.teal.shade700,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditParentScreen(schoolId: schoolId))),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
          double itemWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;
          itemWidth = itemWidth > 0 ? itemWidth.floorToDouble() : 100.0;

          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: actions.map((action) {
              return SizedBox(
                width: itemWidth,
                height: itemWidth * 0.9,
                child: _buildQuickActionItem(
                  context,
                  textTheme,
                  action['title'] as String,
                  action['icon'] as IconData,
                  action['bgColor'] as Color,
                  action['iconBgColor'] as Color,
                  action['iconFgColor'] as Color,
                  action['onTap'] as VoidCallback,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
