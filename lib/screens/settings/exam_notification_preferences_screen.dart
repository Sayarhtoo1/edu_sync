import 'package:flutter/material.dart';
import '../../services/exam_notification_service.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class ExamNotificationPreferencesScreen extends StatefulWidget {
  const ExamNotificationPreferencesScreen({super.key});

  @override
  State<ExamNotificationPreferencesScreen> createState() => _ExamNotificationPreferencesScreenState();
}

class _ExamNotificationPreferencesScreenState extends State<ExamNotificationPreferencesScreen> {
  final _notificationService = ExamNotificationService();
  bool _examReminders = true;
  bool _resultNotifications = true;
  bool _marksDeadlineAlerts = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.getCurrentUser()?.id;
      
      if (userId != null) {
        final prefs = await _notificationService.getNotificationPreferences(userId);
        setState(() {
          _examReminders = prefs['exam_reminders'] ?? true;
          _resultNotifications = prefs['result_notifications'] ?? true;
          _marksDeadlineAlerts = prefs['marks_deadline_alerts'] ?? true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preferences: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.getCurrentUser()?.id;
      
      if (userId != null) {
        await _notificationService.updateNotificationPreferences(
          userId: userId,
          examReminders: _examReminders,
          resultNotifications: _resultNotifications,
          marksDeadlineAlerts: _marksDeadlineAlerts,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences saved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Notifications')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Exam Reminders'),
                  subtitle: const Text('Get notified before exams'),
                  value: _examReminders,
                  onChanged: (value) {
                    setState(() => _examReminders = value);
                    _savePreferences();
                  },
                ),
                SwitchListTile(
                  title: const Text('Result Notifications'),
                  subtitle: const Text('Get notified when results are published'),
                  value: _resultNotifications,
                  onChanged: (value) {
                    setState(() => _resultNotifications = value);
                    _savePreferences();
                  },
                ),
                SwitchListTile(
                  title: const Text('Marks Deadline Alerts'),
                  subtitle: const Text('Get notified about marks entry deadlines'),
                  value: _marksDeadlineAlerts,
                  onChanged: (value) {
                    setState(() => _marksDeadlineAlerts = value);
                    _savePreferences();
                  },
                ),
              ],
            ),
    );
  }
}
