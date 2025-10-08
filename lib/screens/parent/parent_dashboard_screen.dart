import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/widgets/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/widgets/hijri_calendar_card.dart'; // Import HijriCalendarCard
import 'package:edu_sync/widgets/admin_action_card.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';
import 'package:edu_sync/services/notification_service.dart'; // Import NotificationService
import 'package:edu_sync/widgets/in_app_notification_popup.dart'; // Import InAppNotificationPopup
import 'package:provider/provider.dart'; // Import Provider

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  StreamSubscription? _announcementSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToInAppAnnouncements();
  }

  void _subscribeToInAppAnnouncements() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    _announcementSubscription = notificationService.inAppAnnouncements.listen((announcement) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: InAppNotificationPopup(
            announcement: announcement,
            onDismiss: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    });
  }

  @override
  void dispose() {
    _announcementSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

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
      {
        'title': l10n?.reportCardTitle ?? "Report Card",
        'icon': Icons.receipt_long_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => context.go('/parent/report-card/student123/exam456'), // Placeholder IDs, will be replaced with actual student/exam IDs
      },
    ];

    return DashboardScreen(
      title: l10n?.parentDashboardTitle ?? 'Parent Dashboard',
      welcomeMessage: l10n?.parentDashboardWelcomeMessage ?? 'Welcome to your Parent Dashboard',
      appBarActions: [
        Consumer<NotificationService>(
          builder: (context, notificationService, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    context.go('/parent/announcements');
                  },
                ),
                if (notificationService.hasNewAnnouncements)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
      headerWidget: const HijriCalendarCard(), // Add HijriCalendarCard here
      quickActionsSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.quickActions ?? 'Quick Actions',
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
