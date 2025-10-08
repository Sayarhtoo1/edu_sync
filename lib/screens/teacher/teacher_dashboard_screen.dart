import 'dart:async'; // For Timer and StreamSubscription
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // For Provider
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/widgets/dashboard_screen.dart';
import 'package:edu_sync/widgets/admin_action_card.dart'; // Reusing AdminActionCard for quick actions
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';
import 'package:edu_sync/screens/staff/staff_attendance_screen.dart'; // Import StaffAttendanceScreen
import 'package:edu_sync/widgets/hijri_calendar_card.dart'; // Import HijriCalendarCard
import 'package:edu_sync/models/schedule_summary.dart'; // Import ScheduleSummary
import 'package:edu_sync/services/schedule_summary_service.dart'; // Import ScheduleSummaryService
import 'package:edu_sync/services/auth_service.dart'; // Import AuthService
import 'package:edu_sync/services/notification_service.dart'; // Import NotificationService
import 'package:edu_sync/widgets/in_app_notification_popup.dart'; // Import InAppNotificationPopup
import 'package:edu_sync/screens/teacher/exam/input_marks_screen.dart';
// Import timetable_model

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  ScheduleSummary? _scheduleSummary;
  Timer? _timer;
  late final ScheduleSummaryService _scheduleSummaryService;
  late final AuthService _authService;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _scheduleSummaryService = Provider.of<ScheduleSummaryService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _currentUserId = _authService.getCurrentUser()?.id ?? ''; // Initialize with empty string if null

    if (_currentUserId.isNotEmpty) {
      _updateScheduleSummary(); // Fetch initial data only if user ID is available
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateScheduleSummary(); // Update every minute
      });
    }
    _subscribeToInAppAnnouncements();
  }

  StreamSubscription? _announcementSubscription;

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
  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    _announcementSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  Future<void> _updateScheduleSummary() async {
    if (_currentUserId.isEmpty) return; // Check if user ID is empty

    final summary = await _scheduleSummaryService.getDailyScheduleSummary(
      _currentUserId,
      DateTime.now(),
    );
    setState(() {
      _scheduleSummary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Define colors for quick actions (can be moved to a theme file if reused often)
    const Color accentTeachers = Color(0xFFC7E9FF);
    const Color iconBgTeachers = Color(0xFFB3E0FD);
    const Color iconColorTeachers = Color(0xFF3B9EFF);
    const Color accentStudents = Color(0xFFE0C7FF);
    const Color iconBgStudents = Color(0xFFD4D0FB);
    const Color iconColorStudents = Color(0xFF7A6FF0);
    const Color textDarkGrey = Color(0xFF2C2C2C);

    final quickActions = [
      {
        'title': l10n?.teacherTimetable ?? 'Teacher Timetable',
        'icon': Icons.calendar_today_outlined,
        'bgColor': accentTeachers.withAlpha(100),
        'iconBgColor': iconBgTeachers,
        'iconFgColor': iconColorTeachers,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
      },
      {
        'title': l10n?.markAttendance ?? 'Mark Attendance',
        'icon': Icons.check_circle_outline,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen())),
      },
      {
        'title': "Attendance Report",
        'icon': Icons.bar_chart_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceReportScreen())),
      },
      {
        'title': "Staff Attendance",
        'icon': Icons.location_on_outlined,
        'bgColor': accentTeachers.withAlpha(100),
        'iconBgColor': iconBgTeachers,
        'iconFgColor': iconColorTeachers,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffAttendanceScreen())),
      },
      {
        'title': "Input Marks",
        'icon': Icons.edit_note_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InputMarksScreen())),
      },
    ];

    Widget scheduleDisplayWidget;
    if (_scheduleSummary == null) {
      scheduleDisplayWidget = const Center(child: CircularProgressIndicator());
    } else {
      IconData icon;
      Color bgColor;
      Color iconBgColor;
      Color iconFgColor;
      String title;
      String subtitle = '';

      if (_scheduleSummary!.isFree) {
        icon = Icons.check_circle_outline;
        bgColor = Colors.green.shade50.withAlpha(100);
        iconBgColor = Colors.green.shade100;
        iconFgColor = Colors.green.shade700;
        title = l10n?.youAreFreeNow ?? 'You are free now';
      } else if (_scheduleSummary!.currentEntry != null) {
        final entry = _scheduleSummary!.currentEntry!;
        icon = Icons.school;
        bgColor = Colors.blue.shade50.withAlpha(100);
        iconBgColor = Colors.blue.shade100;
        iconFgColor = Colors.blue.shade700;
        title = '${l10n?.currentSubject ?? 'Current Subject'}: ${entry.subjectName} - ${entry.className}';
        subtitle = '${entry.startTimeString} - ${entry.endTimeString}';
      } else if (_scheduleSummary!.nextEntry != null) {
        final entry = _scheduleSummary!.nextEntry!;
        icon = Icons.arrow_forward_ios;
        bgColor = Colors.orange.shade50.withAlpha(100);
        iconBgColor = Colors.orange.shade100;
        iconFgColor = Colors.orange.shade700;
        title = '${entry.subjectName} - ${entry.className}';
        subtitle = '${l10n?.nextSubject ?? 'Next Subject'}: ${entry.startTimeString} - ${entry.endTimeString}';
      } else {
        icon = Icons.event_busy;
        bgColor = Colors.grey.shade50.withAlpha(100);
        iconBgColor = Colors.grey.shade100;
        iconFgColor = Colors.grey.shade700;
        title = l10n?.noScheduleToday ?? 'No schedule today';
      }

      scheduleDisplayWidget = Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor.withOpacity(0.8), bgColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconBgColor,
              child: Icon(icon, color: iconFgColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textDarkGrey,
                      fontSize: 18,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DashboardScreen(
      title: l10n?.teacherDashboardTitle ?? 'Teacher Dashboard',
      welcomeMessage: l10n?.teacherDashboardWelcomeMessage ?? 'Welcome back!',
      appBarActions: [
        Consumer<NotificationService>(
          builder: (context, notificationService, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {
                    context.go('/teacher/announcements');
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
      headerWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HijriCalendarCard(),
          const SizedBox(height: 16),
          scheduleDisplayWidget,
        ],
      ),
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
