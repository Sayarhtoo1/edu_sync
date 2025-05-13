import 'package:flutter/material.dart'; // Import material for ChangeNotifier
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart'; // To parse announcement from Realtime

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _lastSeenAnnouncementTimestampKey = 'last_seen_announcement_timestamp';
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  RealtimeChannel? _announcementsChannel;

  bool _hasNewAnnouncements = false;
  bool get hasNewAnnouncements => _hasNewAnnouncements;

  void _setHasNewAnnouncements(bool value) {
    if (_hasNewAnnouncements != value) {
      _hasNewAnnouncements = value;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission on Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print("Notification permission granted: $granted");
    }
  }

  Future<void> showNotification(
      int id, String title, String body, String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<DateTime?> getLastSeenAnnouncementTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampString = prefs.getString(_lastSeenAnnouncementTimestampKey);
    if (timestampString != null) {
      return DateTime.tryParse(timestampString);
    }
    return null;
  }

  Future<void> setLastSeenAnnouncementTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenAnnouncementTimestampKey, timestamp.toIso8601String());
    // When timestamp is set (i.e., user has likely seen them), clear the new flag
    _setHasNewAnnouncements(false);
  }

  // Call this after user logs in and schoolId is known
  void subscribeToAnnouncements(int schoolId, String currentUserId, String currentUserRole) {
    if (_announcementsChannel != null) {
      _supabaseClient.removeChannel(_announcementsChannel!);
    }
    print('Subscribing to announcements for school: $schoolId');
    _announcementsChannel = _supabaseClient
        .channel('public:announcements:school_id=eq.$schoolId') // Listen to inserts for the specific school
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'announcements',
            filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'school_id', value: schoolId),
            callback: (payload) async {
              print('New announcement received via Realtime: ${payload.newRecord}');
              final newAnnouncementMap = payload.newRecord;
              final newAnnouncement = Announcement.fromMap(newAnnouncementMap);
              
              // Basic RLS check simulation (actual RLS is on DB)
              // This client-side check is just to avoid unnecessary notifications if possible
              bool isTargeted = false;
              if (currentUserRole == 'Admin') { // Admins are targeted for all announcements in their school
                isTargeted = true;
              } else if (newAnnouncement.targetRole == 'All') {
                isTargeted = true;
              } else if (newAnnouncement.targetRole == currentUserRole) { // e.g., targetRole 'Teacher' and currentUserRole is 'Teacher'
                isTargeted = true;
              }
              // Note: 'SpecificClass' targeting for notifications would require more complex client-side data
              // (e.g. knowing the parent's children's classes, or teacher's classes).
              // For now, 'SpecificClass' announcements might not trigger client-side notifications via this simple check
              // unless the user is an Admin. They will still see it when they load the announcements screen due to RLS.

              if (isTargeted) {
                final lastSeen = await getLastSeenAnnouncementTimestamp();
                if (lastSeen == null || newAnnouncement.createdAt.isAfter(lastSeen)) {
                  print("Setting hasNewAnnouncements to true for user role: $currentUserRole");
                  _setHasNewAnnouncements(true);
                  // Show an immediate local notification
                  await showNotification(
                    newAnnouncement.id, 
                    "New Announcement: ${newAnnouncement.title}", 
                    newAnnouncement.content.length > 50 ? "${newAnnouncement.content.substring(0,50)}..." : newAnnouncement.content, 
                    "announcement_${newAnnouncement.id}"
                  );
                }
              }
                        })
        .subscribe((status, [_]) async {
            if (status == 'SUBSCRIBED') {
                print('Successfully subscribed to announcements channel!');
            } else if (status == 'CHANNEL_ERROR') {
                print('Error subscribing to announcements channel.');
            } else if (status == 'TIMED_OUT') {
                print('Announcements channel subscription timed out.');
            }
        });
  }

  void unsubscribeFromAnnouncements() {
    if (_announcementsChannel != null) {
      print('Unsubscribing from announcements channel.');
      _supabaseClient.removeChannel(_announcementsChannel!);
      _announcementsChannel = null;
    }
  }

  // Call this when the app is disposed or user logs out
  @override
  void dispose() {
    unsubscribeFromAnnouncements();
    super.dispose();
  }
}
