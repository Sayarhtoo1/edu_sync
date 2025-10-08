import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/admin/teacher_status_overview_screen.dart';
import 'package:edu_sync/screens/staff/staff_attendance_screen.dart';
import 'package:edu_sync/screens/admin/exam/modern_exam_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/subject_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/grade_management_screen.dart';
import 'package:edu_sync/screens/teacher/exam/input_marks_screen.dart';
import 'package:edu_sync/screens/admin/fee/fee_structure_management_screen.dart';
import 'package:edu_sync/screens/admin/fee/donation_management_screen.dart';
import 'package:edu_sync/widgets/admin_action_card.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }
    final textTheme = Theme.of(context).textTheme;
    const Color textDarkGrey = Color(0xFF2C2C2C);

    final actionCategories = [
      {
        'category': 'Communication',
        'actions': [
          {
            'title': l10n.announcementsAction ?? 'Announcements',
            'icon': Icons.campaign_outlined,
            'bgColor': const Color(0xFFE3F2FD),
            'iconBgColor': const Color(0xFF2196F3),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
          },
        ],
      },
      {
        'category': 'Attendance',
        'actions': [
          {
            'title': l10n.markAttendance ?? 'Student Attendance',
            'icon': Icons.how_to_reg_outlined,
            'bgColor': const Color(0xFFE8F5E9),
            'iconBgColor': const Color(0xFF4CAF50),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen())),
          },
          {
            'title': l10n.markStaffAttendanceTitle ?? 'Staff Attendance',
            'icon': Icons.badge_outlined,
            'bgColor': const Color(0xFFFFF3E0),
            'iconBgColor': const Color(0xFFFF9800),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffAttendanceScreen())),
          },
          {
            'title': "Attendance Report",
            'icon': Icons.assessment_outlined,
            'bgColor': const Color(0xFFF3E5F5),
            'iconBgColor': const Color(0xFF9C27B0),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceReportScreen())),
          },
        ],
      },
      {
        'category': 'Academic',
        'actions': [
          {
            'title': "Exam Management",
            'icon': Icons.assignment_outlined,
            'bgColor': const Color(0xFFE1F5FE),
            'iconBgColor': const Color(0xFF03A9F4),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ModernExamManagementScreen())),
          },
          {
            'title': "Subject Management",
            'icon': Icons.menu_book_outlined,
            'bgColor': const Color(0xFFFCE4EC),
            'iconBgColor': const Color(0xFFE91E63),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubjectManagementScreen())),
          },
          {
            'title': "Grade Management",
            'icon': Icons.grade_outlined,
            'bgColor': const Color(0xFFFFF9C4),
            'iconBgColor': const Color(0xFFFBC02D),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GradeManagementScreen())),
          },
          {
            'title': "Input Marks",
            'icon': Icons.edit_note_outlined,
            'bgColor': const Color(0xFFE0F2F1),
            'iconBgColor': const Color(0xFF009688),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InputMarksScreen())),
          },
        ],
      },
      {
        'category': 'Schedule & Staff',
        'actions': [
          {
            'title': l10n.teacherTimetable ?? 'Timetable',
            'icon': Icons.schedule_outlined,
            'bgColor': const Color(0xFFEDE7F6),
            'iconBgColor': const Color(0xFF673AB7),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
          },
          {
            'title': l10n.teacherStatusOverviewTitle ?? 'Teacher Overview',
            'icon': Icons.people_outline,
            'bgColor': const Color(0xFFE8EAF6),
            'iconBgColor': const Color(0xFF3F51B5),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherStatusOverviewScreen())),
          },
        ],
      },
      {
        'category': 'Finance',
        'actions': [
          {
            'title': "Fee Management",
            'icon': Icons.account_balance_wallet_outlined,
            'bgColor': const Color(0xFFE3F2FD),
            'iconBgColor': const Color(0xFF1976D2),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeeStructureManagementScreen())),
          },
          {
            'title': "Donations",
            'icon': Icons.favorite_border_outlined,
            'bgColor': const Color(0xFFFFEBEE),
            'iconBgColor': const Color(0xFFF44336),
            'iconFgColor': Colors.white,
            'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DonationManagementScreen())),
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions ?? 'Quick Actions',
          style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...actionCategories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Text(
                  category['category'] as String,
                  style: textTheme.titleSmall?.copyWith(
                    color: textDarkGrey.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                double itemWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;
                itemWidth = itemWidth > 0 ? itemWidth.floorToDouble() : 100.0;

                final actions = category['actions'] as List;
                return Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: actions.map((action) {
                    return SizedBox(
                      width: itemWidth,
                      height: itemWidth * 0.9,
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
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }
}
