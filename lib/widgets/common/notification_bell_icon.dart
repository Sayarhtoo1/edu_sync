import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/screens/common/announcements_list_screen.dart';

class NotificationBellIcon extends StatefulWidget {
  const NotificationBellIcon({super.key});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final announcementService = context.read<AnnouncementService>();
    final authService = context.read<AuthService>();
    final schoolProvider = context.read<SchoolProvider>();
    
    final user = authService.getCurrentUser();
    final schoolId = schoolProvider.currentSchool?.id;
    
    if (user != null && schoolId != null) {
      final userDetails = await authService.getUserById(user.id);
      final userRole = userDetails?.role ?? 'user';
      
      final allAnnouncements = await announcementService.getAnnouncements(schoolId);
      final announcements = allAnnouncements.where((a) => 
        a.targetRole == null || a.targetRole == 'All' || a.targetRole == userRole
      ).toList();
      final unread = announcements.where((a) => DateTime.now().difference(a.createdAt).inHours < 24).length;
      
      if (mounted) {
        setState(() => _unreadCount = unread);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnnouncementsListScreen()),
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
