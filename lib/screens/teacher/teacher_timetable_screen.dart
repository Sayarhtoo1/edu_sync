import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:edu_sync/l10n/gen/app_localizations.dart';
import '../../models/timetable.dart' as timetable_model;
import '../../models/school_class.dart' as app_class;
import '../../services/timetable_service.dart';
import '../../services/class_service.dart';
import '../../providers/school_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> with SingleTickerProviderStateMixin {
  late final TimetableService _timetableService;
  late final ClassService _classService;
  late final AuthService _authService;
  late final String _currentUserId;
  int? _currentSchoolId;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isLoading = true;
  String? _errorMessage;
  List<timetable_model.Timetable> _timetableEntries = [];
  Map<int, app_class.SchoolClass> _classMap = {};
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    
    _timetableService = Provider.of<TimetableService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _currentUserId = _authService.getCurrentUser()?.id ?? '';
    
    _initializeNotifications();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolIdAndFetchTimetable();
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(settings);
    
    // Request exact alarm permission for Android 12+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> _loadSchoolIdAndFetchTimetable() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    // Ensure school data is loaded if not already
    if (schoolProvider.currentSchool == null) {
      // Assuming SchoolProvider has a method to load school data if not present
      // This might involve fetching based on user's association or a default
      // For now, let's assume it might be null and handle it.
      // Or, we can try to load it.
      // await schoolProvider.fetchSchoolForUser(_currentUserId); // Example
    }
    _currentSchoolId = schoolProvider.currentSchool?.id;

    if (_currentUserId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.error_user_not_found; // Assert non-null
      });
      return;
    }

    if (_currentSchoolId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.error_school_not_selected_or_found; // Assert non-null
      });
      return;
    }
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all classes to build the class map
      if (_currentSchoolId != null) {
        final allClasses = await _classService.getClasses(_currentSchoolId!);
        _classMap = {for (var cls in allClasses) cls.id!: cls};
      }

      // Fetch all timetable entries for the teacher
      final allEntries = await _timetableService.getTimetableForTeacher(_currentUserId);

      // Filter entries for the selected day
      final selectedDayName = DateFormat('EEEE').format(_selectedDate); // e.g., "Monday"
      final entriesForSelectedDay = allEntries
          .where((entry) => entry.dayOfWeek == selectedDayName)
          .toList();

      // Sort entries by start time
      entriesForSelectedDay.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));
      
      // Schedule notifications only for today's future classes
      final today = DateTime.now();
      if (_selectedDate.year == today.year && 
          _selectedDate.month == today.month && 
          _selectedDate.day == today.day) {
        _scheduleNotifications(entriesForSelectedDay);
      }

      setState(() {
        _timetableEntries = entriesForSelectedDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${AppLocalizations.of(context)!.error_fetching_timetable}: ${e.toString()}'; // Assert non-null
      });
    }
  }

  void _changeSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchTimetable();
  }
  
  Future<void> _scheduleNotifications(List<timetable_model.Timetable> entries) async {
    await _notificationsPlugin.cancelAll();
    
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final startTime = _parseTime(entry.startTimeString);
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute).subtract(const Duration(minutes: 10));
      
      if (scheduledTime.isAfter(now)) {
        final className = _classMap[entry.classId]?.name ?? 'Class';
        await _notificationsPlugin.zonedSchedule(
          i,
          'Upcoming Class: ${entry.subjectName}',
          '$className starts in 10 minutes at ${entry.startTimeString}',
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'timetable_channel',
              'Timetable Notifications',
              channelDescription: 'Notifications for upcoming classes',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
              fullScreenIntent: true,
              visibility: NotificationVisibility.public,
              channelShowBadge: true,
              autoCancel: false,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.my_timetable_title),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: contextualAccentColor),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: contextualAccentColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                _changeSelectedDate(picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateNavigator(contextualAccentColor, theme),
          Expanded(child: _buildBody(l10n, contextualAccentColor)),
        ],
      ),
    );
  }

  Widget _buildDateNavigator(Color accentColor, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: accentColor),
            onPressed: () => _changeSelectedDate(_selectedDate.subtract(const Duration(days: 1))),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(color: accentColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, yyyy').format(_selectedDate),
                style: theme.textTheme.bodySmall?.copyWith(color: textDarkGrey.withOpacity(0.6)),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: accentColor),
            onPressed: () => _changeSelectedDate(_selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, Color accentColor) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_timetableEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: accentColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(l10n.no_timetable_entries_found, style: TextStyle(fontSize: 16, color: textDarkGrey.withOpacity(0.6))),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _timetableEntries.length,
        itemBuilder: (context, index) {
          final entry = _timetableEntries[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildEnhancedTimetableCard(entry, accentColor, theme, index),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedTimetableCard(timetable_model.Timetable entry, Color accentColor, ThemeData theme, int index) {
    final className = _classMap[entry.classId]?.name ?? 'Unknown Class';
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year && 
                    _selectedDate.month == today.month && 
                    _selectedDate.day == today.day;
    
    String status;
    Color statusColor;
    IconData statusIcon;
    Gradient? gradient;
    
    if (isToday) {
      final now = TimeOfDay.now();
      final start = _parseTime(entry.startTimeString);
      final end = _parseTime(entry.endTimeString);
      
      if (_isAfter(now, end)) {
        status = 'Done';
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle_rounded;
        gradient = LinearGradient(colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)]);
      } else if (_isBetween(now, start, end)) {
        status = 'In Progress';
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.play_circle_rounded;
        gradient = LinearGradient(colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)]);
      } else {
        status = 'Coming';
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.schedule_rounded;
        gradient = LinearGradient(colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)]);
      }
    } else if (_selectedDate.isBefore(DateTime(today.year, today.month, today.day))) {
      status = 'Past';
      statusColor = Colors.grey;
      statusIcon = Icons.history_rounded;
      gradient = LinearGradient(colors: [statusColor.withOpacity(0.08), statusColor.withOpacity(0.03)]);
    } else {
      status = 'Scheduled';
      statusColor = const Color(0xFF9C27B0);
      statusIcon = Icons.event_rounded;
      gradient = LinearGradient(colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)]);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.startTimeString} - ${entry.endTimeString}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.book_rounded, color: statusColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.subjectName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.class_rounded, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  className,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  
  bool _isAfter(TimeOfDay time, TimeOfDay other) {
    return time.hour > other.hour || (time.hour == other.hour && time.minute > other.minute);
  }
  
  bool _isBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }


}
