import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/notification_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/parent/parent_drawer.dart';
import 'package:edu_sync/widgets/announcement_popup_dialog.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';

class ModernParentDashboard extends StatefulWidget {
  const ModernParentDashboard({super.key});

  @override
  State<ModernParentDashboard> createState() => _ModernParentDashboardState();
}

class _ModernParentDashboardState extends State<ModernParentDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _parentName;
  StreamSubscription? _announcementSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    _announcementSubscription = notificationService.inAppAnnouncements.listen((announcement) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AnnouncementPopupDialog(
            announcement: announcement,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        );
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = context.read<AuthService>();
      final user = authService.getCurrentUser();
      if (user != null) {
        final userDetails = await authService.getUserById(user.id);
        if (mounted) {
          setState(() => _parentName = userDetails?.fullName ?? user.email?.split('@')[0]);
        }
      }
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _announcementSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Consumer<SchoolProvider>(
              builder: (context, schoolProvider, _) {
                final schoolLogo = schoolProvider.currentSchool?.logoUrl;
                return Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: schoolLogo != null && schoolLogo.isNotEmpty
                      ? Image.network(schoolLogo, fit: BoxFit.contain)
                      : const Icon(Icons.school, size: 20, color: Colors.grey),
                );
              },
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Parent Dashboard',
                style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const ParentDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_parentName ?? 'Parent', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Consumer<SchoolProvider>(
            builder: (context, schoolProvider, _) {
              final schoolLogo = schoolProvider.currentSchool?.logoUrl;
              return Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: schoolLogo != null && schoolLogo.isNotEmpty
                    ? Image.network(schoolLogo, fit: BoxFit.contain)
                    : const Icon(Icons.school_rounded, color: Colors.white, size: 32),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Attendance', 'icon': Icons.how_to_reg_outlined, 'color': const Color(0xFF2196F3), 'screen': const AttendanceReportScreen()},
      {'title': 'Child Attendance', 'icon': Icons.calendar_today_outlined, 'color': const Color(0xFF9C27B0), 'route': '/parent/child-attendance'},
      {'title': 'Child Schedule', 'icon': Icons.schedule_outlined, 'color': const Color(0xFFFF9800), 'route': '/parent/child-schedule'},
      {'title': 'Announcements', 'icon': Icons.campaign_outlined, 'color': const Color(0xFF4CAF50), 'route': '/parent/announcements'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (action['screen'] != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget));
                  } else if (action['route'] != null) {
                    Navigator.pushNamed(context, action['route'] as String);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, color: action['color'] as Color, size: 32),
                      const SizedBox(height: 8),
                      Text(action['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
