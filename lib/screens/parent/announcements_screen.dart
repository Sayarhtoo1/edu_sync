import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/announcement.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/auth_service.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/services/notification_service.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final AuthService _authService = AuthService(); 
  final NotificationService _notificationService = NotificationService(); // Add NotificationService instance

  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _schoolId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _userRole = _authService.getUserRole(); // Get current user's role

    if (_schoolId != null) {
      _loadAnnouncements();
    } else {
      // This should ideally be handled before navigating to this screen
      // For example, ensure school context is loaded after login.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = AppLocalizations.of(context).error_school_not_selected_or_found ?? "School not selected.";
          });
        }
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    if (_schoolId == null) return;
    setState(() => _isLoading = true);
    try {
      final fetchedAnnouncements = await _announcementService.getAnnouncements(_schoolId!);
      final lastSeenTimestamp = await _notificationService.getLastSeenAnnouncementTimestamp();
      DateTime latestTimestampInCurrentFetch = DateTime(1970); // Initialize with a very old date

      List<Announcement> newAnnouncementsForNotification = [];

      if (fetchedAnnouncements.isNotEmpty) {
         latestTimestampInCurrentFetch = fetchedAnnouncements.first.createdAt; // Assuming sorted by date desc
      }

      for (var announcement in fetchedAnnouncements) {
        if (lastSeenTimestamp == null || announcement.createdAt.isAfter(lastSeenTimestamp)) {
          newAnnouncementsForNotification.add(announcement);
        }
      }
      
      _announcements = fetchedAnnouncements;

      if (mounted) {
        setState(() => _isLoading = false);
      }

      // Show notifications for new announcements
      // Stagger notifications slightly if there are many, or show a summary notification.
      // For simplicity, show one for each new one.
      for (int i = 0; i < newAnnouncementsForNotification.length; i++) {
        final ann = newAnnouncementsForNotification[i];
        // Use a unique ID for each notification, e.g., announcement.id
        // The payload can be used to navigate to a specific announcement if tapped.
        await _notificationService.showNotification(
          ann.id, // Use announcement ID as notification ID
          ann.title,
          ann.content.length > 100 ? '${ann.content.substring(0, 100)}...' : ann.content, // Truncate body
          'announcement_${ann.id}' // Example payload
        );
        await Future.delayed(const Duration(milliseconds: 500)); // Slight delay between multiple notifications
      }

      // Update last seen timestamp to the newest announcement from this fetch
      if (fetchedAnnouncements.isNotEmpty) {
        await _notificationService.setLastSeenAnnouncementTimestamp(latestTimestampInCurrentFetch);
      }

    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _errorMessage = "${l10n.errorOccurredPrefix}: ${e.toString()}");
      }
    } finally {
       if (mounted && _isLoading) { // Ensure isLoading is reset if an error occurred before it was set to false
         setState(() => _isLoading = false);
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('announcement');

    return Scaffold(
      appBar: AppBar( // Theme applied globally
        title: Text(l10n.announcementsTitle), 
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))))
              : _announcements.isEmpty
                  ? Center(child: Text(l10n.noAnnouncementsFound, style: theme.textTheme.bodyLarge)) 
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      color: contextualAccentColor,
                      child: ListView.builder(
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = _announcements[index];
                          return Card( // CardTheme applied globally
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted margin
                            child: Padding( // Added padding inside card
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(announcement.title, style: theme.textTheme.titleLarge?.copyWith(color: contextualAccentColor)),
                                  const SizedBox(height: 8),
                                  Text(announcement.content, style: theme.textTheme.bodyMedium),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${l10n.postedOn} ${DateFormat.yMMMd(l10n.localeName).format(announcement.createdAt)}', 
                                    style: theme.textTheme.bodySmall?.copyWith(color: textLightGrey), // Use top-level constant
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
