import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/widgets/dashboard_screen.dart';
import 'package:edu_sync/widgets/hijri_calendar_card.dart'; // Import HijriCalendarCard
import 'package:edu_sync/widgets/admin_action_card.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    const Color accentStudents = Color(0xFFE0C7FF);
    const Color iconBgStudents = Color(0xFFD4D0FB);
    const Color iconColorStudents = Color(0xFF7A6FF0);
    const Color textDarkGrey = Color(0xFF2C2C2C);

    final quickActions = [
      {
        'title': "Attendance Report",
        'icon': Icons.bar_chart_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceReportScreen())),
      },
    ];

    return DashboardScreen(
      title: l10n.parentDashboardTitle,
      welcomeMessage: l10n.parentDashboardWelcomeMessage,
      headerWidget: const HijriCalendarCard(), // Add HijriCalendarCard here
      quickActionsSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
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
              children: quickActions.map((action) {
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
        ],
      ),
    );
  }
}
