import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/admin/teacher_status_overview_screen.dart'; // Import the new screen
import 'package:edu_sync/widgets/admin_action_card.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    const Color textDarkGrey = Color(0xFF2C2C2C);
    const Color accentStudents = Color(0xFFE0C7FF);
    const Color iconBgStudents = Color(0xFFD4D0FB);
    const Color iconColorStudents = Color(0xFF7A6FF0);
    const Color accentTeachers = Color(0xFFC7E9FF);
    const Color iconBgTeachers = Color(0xFFB3E0FD);
    const Color iconColorTeachers = Color(0xFF3B9EFF);
    const Color accentParents = Color(0xFFFFD6C7);
    const Color iconBgParents = Color(0xFFFFDAB3);
    const Color iconColorParents = Color(0xFFFFA726);
    const Color accentEarnings = Color(0xFFD5F5D1);
    const Color iconBgEarnings = Color(0xFFC8E6C9);
    const Color iconColorEarnings = Color(0xFF4CAF50);

    final actions = [
      {
        'title': l10n.announcementsAction, // "Announcements"
        'icon': Icons.campaign_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
      },
      {
        'title': l10n.teacherTimetable, // "Teacher Timetable"
        'icon': Icons.calendar_today_outlined,
        'bgColor': accentTeachers.withAlpha(100),
        'iconBgColor': iconBgTeachers,
        'iconFgColor': iconColorTeachers,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
      },
      {
        'title': l10n.markAttendance, // "Mark Attendance"
        'icon': Icons.check_circle_outline,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen())),
      },
      {
        'title': "Attendance Report",
        'icon': Icons.bar_chart_outlined,
        'bgColor': accentEarnings.withAlpha(100),
        'iconBgColor': iconBgEarnings,
        'iconFgColor': iconColorEarnings,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceReportScreen())),
      },
      {
        'title': l10n.teacherStatusOverviewTitle, // "Teacher Status Overview"
        'icon': Icons.group_outlined,
        'bgColor': accentTeachers.withAlpha(100),
        'iconBgColor': iconBgTeachers,
        'iconFgColor': iconColorTeachers,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherStatusOverviewScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions, // "Quick Actions"
          style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600),
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
                height: itemWidth * 0.9, // Maintain aspect ratio slightly
                child: AdminActionCard(
                  title: action['title'] as String,
                  icon: action['icon'] as IconData,
                  bgColor: action['bgColor'] as Color,
                  iconBgColor: action['iconBgColor'] as Color,
                  iconFgColor: action['iconFgColor'] as Color,
                  onTap: action['onTap'] as VoidCallback,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
