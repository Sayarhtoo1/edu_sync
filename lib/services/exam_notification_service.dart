import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';

class ExamNotificationService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> scheduleExamReminder({
    required String examId,
    required String examName,
    required DateTime examDate,
  }) async {
    try {
      final reminderDate = examDate.subtract(const Duration(days: 1));
      
      await _supabaseClient.from('exam_notifications').insert({
        'exam_id': examId,
        'notification_type': 'exam_reminder',
        'title': 'Exam Reminder',
        'message': 'Exam "$examName" is scheduled for tomorrow',
        'scheduled_at': reminderDate.toIso8601String(),
        'target_roles': ['Student', 'Parent', 'Teacher'],
      });
    } catch (e) {
      logger.e('Error scheduling exam reminder: $e');
    }
  }

  Future<void> notifyResultPublished({
    required String examId,
    required String examName,
  }) async {
    try {
      await _supabaseClient.from('exam_notifications').insert({
        'exam_id': examId,
        'notification_type': 'result_published',
        'title': 'Results Published',
        'message': 'Results for "$examName" are now available',
        'scheduled_at': DateTime.now().toIso8601String(),
        'target_roles': ['Student', 'Parent'],
      });

      await _showLocalNotification(
        title: 'Results Published',
        body: 'Results for "$examName" are now available',
      );
    } catch (e) {
      logger.e('Error notifying result published: $e');
    }
  }

  Future<void> notifyMarksDeadline({
    required String examId,
    required String examName,
    required DateTime deadline,
  }) async {
    try {
      await _supabaseClient.from('exam_notifications').insert({
        'exam_id': examId,
        'notification_type': 'marks_deadline',
        'title': 'Marks Entry Deadline',
        'message': 'Deadline for entering marks for "$examName" is approaching',
        'scheduled_at': deadline.subtract(const Duration(hours: 24)).toIso8601String(),
        'target_roles': ['Teacher', 'Admin'],
      });
    } catch (e) {
      logger.e('Error notifying marks deadline: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'exam_channel',
      'Exam Notifications',
      channelDescription: 'Notifications for exam updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<Map<String, dynamic>> getNotificationPreferences(String userId) async {
    try {
      final response = await _supabaseClient
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response ?? {
        'exam_reminders': true,
        'result_notifications': true,
        'marks_deadline_alerts': true,
      };
    } catch (e) {
      logger.e('Error getting notification preferences: $e');
      return {
        'exam_reminders': true,
        'result_notifications': true,
        'marks_deadline_alerts': true,
      };
    }
  }

  Future<void> updateNotificationPreferences({
    required String userId,
    required bool examReminders,
    required bool resultNotifications,
    required bool marksDeadlineAlerts,
  }) async {
    try {
      await _supabaseClient.from('notification_preferences').upsert({
        'user_id': userId,
        'exam_reminders': examReminders,
        'result_notifications': resultNotifications,
        'marks_deadline_alerts': marksDeadlineAlerts,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      logger.e('Error updating notification preferences: $e');
      rethrow;
    }
  }
}
