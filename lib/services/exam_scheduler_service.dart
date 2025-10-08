import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/exam.dart';

class ExamSchedulerService {
  static final ExamSchedulerService _instance = ExamSchedulerService._internal();
  factory ExamSchedulerService() => _instance;
  ExamSchedulerService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permissions
    await _requestPermissions();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleExamReminders(List<Exam> exams) async {
    await initialize();

    // Cancel existing notifications
    await _notifications.cancelAll();

    for (final exam in exams) {
      await _scheduleExamNotification(exam);
    }
  }

  Future<void> _scheduleExamNotification(Exam exam) async {
    // Schedule reminder 1 day before exam
    await _scheduleNotification(
      id: exam.id.hashCode,
      title: 'Upcoming Exam Reminder',
      body: 'You have an exam "${exam.name}" scheduled for tomorrow',
      scheduledDate: exam.examDate.subtract(const Duration(days: 1)),
      payload: 'exam_reminder_${exam.id}',
    );

    // Schedule reminder 1 hour before exam
    await _scheduleNotification(
      id: exam.id.hashCode + 1000,
      title: 'Exam Starting Soon',
      body: 'Your exam "${exam.name}" starts in 1 hour',
      scheduledDate: exam.examDate.subtract(const Duration(hours: 1)),
      payload: 'exam_start_${exam.id}',
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'exam_reminders',
      'Exam Reminders',
      channelDescription: 'Notifications for upcoming exams',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelExamReminders(String examId) async {
    await _notifications.cancel(examId.hashCode);
    await _notifications.cancel(examId.hashCode + 1000);
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'exam_instant',
      'Exam Notifications',
      channelDescription: 'Instant exam notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
